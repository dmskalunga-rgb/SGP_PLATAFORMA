$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $taskRoot
New-Item -ItemType Directory -Force artifacts | Out-Null
function Invoke-GateCommand([string]$Name, [scriptblock]$Action) {
  $savedPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = 'Continue'
    & $Action 2>&1 | Tee-Object -FilePath (Join-Path $taskRoot "artifacts/$Name.log")
    $taskExit = $LASTEXITCODE
  } finally { $ErrorActionPreference = $savedPreference }
  if ($taskExit -ne 0) { throw "$Name failed with exit $taskExit" }
}
$testContainer = 'sgp-m0-r1-' + [guid]::NewGuid().ToString('N').Substring(0,12)
$env:NODE_ENV = 'test'
function New-TestSecret {
  $bytes = New-Object byte[] 24
  $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
  try { $rng.GetBytes($bytes); return ([BitConverter]::ToString($bytes)).Replace('-', '') }
  finally { $rng.Dispose() }
}
$env:POSTGRES_PASSWORD = New-TestSecret
$env:RUNTIME_PASSWORD = New-TestSecret
$env:DATABASE_URL = 'postgresql://sgp_owner:' + $env:POSTGRES_PASSWORD + '@127.0.0.1:55433/sgp_test'
try {
  & docker run --rm -d --name $testContainer --env POSTGRES_PASSWORD --env POSTGRES_USER=sgp_owner --env POSTGRES_DB=sgp_test -p 127.0.0.1:55433:5432 sgp-postgres:m0 | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'PostgreSQL failed to start' }
  $ready = $false
  for ($attempt=0; $attempt -lt 60; $attempt++) {
    & docker exec $testContainer pg_isready -h 127.0.0.1 -U sgp_owner -d sgp_test *> $null
    if ($LASTEXITCODE -eq 0) { $ready = $true; break }
    Start-Sleep -Seconds 1
  }
  if (-not $ready) { throw 'PostgreSQL readiness timeout' }
  Invoke-GateCommand 'migration' { npm run migrate }
  Invoke-GateCommand 'tests' { npm test }
  Invoke-GateCommand 'test-runtime-role' { node scripts/provision-test-runtime.mjs }
  $env:DATABASE_URL = 'postgresql://sgp_runtime:' + $env:RUNTIME_PASSWORD + '@127.0.0.1:55433/sgp_test'
  if (Test-Path -LiteralPath 'C:/Program Files/Google/Chrome/Application/chrome.exe') { $env:BROWSER_PATH='C:/Program Files/Google/Chrome/Application/chrome.exe' }
  Invoke-GateCommand 'frontend' { npm run test:frontend }
  & docker exec $testContainer psql -U sgp_owner -d sgp_test -c "SELECT rolname, rolsuper, rolcreaterole, rolcreatedb, rolbypassrls FROM pg_roles WHERE rolname='sgp_runtime';" | Set-Content -Encoding utf8 artifacts/runtime-db-role.log
} finally {
  & docker stop $testContainer *> $null
  Remove-Item Env:POSTGRES_PASSWORD,Env:RUNTIME_PASSWORD,Env:DATABASE_URL -ErrorAction SilentlyContinue
}
