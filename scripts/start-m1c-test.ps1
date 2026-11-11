$ErrorActionPreference='Stop'
Set-Location -LiteralPath (Split-Path $PSScriptRoot -Parent)
New-Item -ItemType Directory -Force .test-secrets | Out-Null
function New-TestSecret { $bytes=New-Object byte[] 32; $rng=[Security.Cryptography.RandomNumberGenerator]::Create();try{$rng.GetBytes($bytes);return [Convert]::ToBase64String($bytes).Replace('+','x').Replace('/','y').Replace('=','')}finally{$rng.Dispose()} }
$env:POSTGRES_PASSWORD=New-TestSecret
$runtimeSecret=New-TestSecret
$authSecret=New-TestSecret
$testPort=55434
$name='sgp-m1c-test-db'
$config=@{owner="postgresql://sgp_owner:$($env:POSTGRES_PASSWORD)@127.0.0.1:$testPort/sgp_test";runtime="postgresql://app_runtime:${runtimeSecret}@127.0.0.1:$testPort/sgp_test";auth="postgresql://auth_runtime:${authSecret}@127.0.0.1:$testPort/sgp_test";container=$name}
$config | ConvertTo-Json | Set-Content -Encoding utf8 .test-secrets/m1c-db.json
docker run --rm -d --name $name --env POSTGRES_PASSWORD --env POSTGRES_USER=sgp_owner --env POSTGRES_DB=sgp_test -p "127.0.0.1:${testPort}:5432" sgp-postgres:m0 -c log_parameter_max_length=0 -c log_parameter_max_length_on_error=0 -c log_min_error_statement=panic
if($LASTEXITCODE -ne 0){throw 'TEST PostgreSQL start failed'}
Remove-Item Env:POSTGRES_PASSWORD
for($i=0;$i -lt 40;$i++){docker exec $name pg_isready -U sgp_owner -d sgp_test *> $null;if($LASTEXITCODE -eq 0){break};Start-Sleep -Seconds 1}
