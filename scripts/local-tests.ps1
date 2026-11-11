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
$env:AUTH_PASSWORD = New-TestSecret
$env:DATABASE_URL = 'postgresql://sgp_owner:' + $env:POSTGRES_PASSWORD + '@127.0.0.1:55433/sgp_test'
$taskOwnerUrl = $env:DATABASE_URL
$taskAuthUrl = 'postgresql://auth_runtime:' + $env:AUTH_PASSWORD + '@127.0.0.1:55433/sgp_test'
$env:APP_DATABASE_URL = 'postgresql://app_runtime:' + $env:RUNTIME_PASSWORD + '@127.0.0.1:55433/sgp_test'
$env:AUTH_DATABASE_URL = $taskAuthUrl
try {
  & docker run --rm -d --name $testContainer --env POSTGRES_PASSWORD --env POSTGRES_USER=sgp_owner --env POSTGRES_DB=sgp_test -p 127.0.0.1:55433:5432 sgp-postgres:m0 -c log_parameter_max_length=0 -c log_parameter_max_length_on_error=0 -c log_min_error_statement=panic | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'PostgreSQL failed to start' }
  $ready = $false
  for ($attempt=0; $attempt -lt 60; $attempt++) {
    & docker exec $testContainer pg_isready -h 127.0.0.1 -U sgp_owner -d sgp_test *> $null
    if ($LASTEXITCODE -eq 0) { $ready = $true; break }
    Start-Sleep -Seconds 1
  }
  if (-not $ready) { throw 'PostgreSQL readiness timeout' }
  Invoke-GateCommand 'migration' { npm run migrate }
  Invoke-GateCommand 'auth-test-runtime-roles' { node scripts/provision-auth-test.mjs }
  Invoke-GateCommand 'tests' { npm test }
  Invoke-GateCommand 'test-runtime-role' { node scripts/provision-test-runtime.mjs }
  $env:DATABASE_URL = 'postgresql://sgp_runtime:' + $env:RUNTIME_PASSWORD + '@127.0.0.1:55433/sgp_test'
  $env:AUTH_DATABASE_URL = ''
  if (Test-Path -LiteralPath 'C:/Program Files/Google/Chrome/Application/chrome.exe') { $env:BROWSER_PATH='C:/Program Files/Google/Chrome/Application/chrome.exe' }
  Invoke-GateCommand 'frontend' { npm run test:frontend }
  $env:DATABASE_URL = $taskOwnerUrl
  $env:AUTH_DATABASE_URL = $taskAuthUrl
  New-Item -ItemType Directory -Force .test-secrets | Out-Null
  Invoke-GateCommand 'test-tls' { openssl req -x509 -newkey rsa:2048 -nodes -days 2 -keyout .test-secrets/test-tls.key -out .test-secrets/test-tls.crt -subj /CN=localhost -addext 'subjectAltName=IP:127.0.0.1,DNS:localhost' }
  Invoke-GateCommand 'auth-browser-fixtures' { node scripts/prepare-auth-browser.mjs }
  Invoke-GateCommand 'auth-frontend' { npx playwright test -c playwright.auth.config.mjs }
  Invoke-GateCommand 'auth-browser-report' { node scripts/summarize-auth-browser.mjs }
  Invoke-GateCommand 'argon2-calibration' { node scripts/calibrate-argon2.mjs }
  & docker exec $testContainer psql -U sgp_owner -d sgp_test -c "SELECT rolname, rolsuper, rolcreaterole, rolcreatedb, rolbypassrls FROM pg_roles WHERE rolname='sgp_runtime';" | Set-Content -Encoding utf8 artifacts/runtime-db-role.log
} finally {
  & docker stop $testContainer *> $null
  Remove-Item Env:POSTGRES_PASSWORD,Env:RUNTIME_PASSWORD,Env:AUTH_PASSWORD,Env:DATABASE_URL,Env:APP_DATABASE_URL,Env:AUTH_DATABASE_URL -ErrorAction SilentlyContinue
}
