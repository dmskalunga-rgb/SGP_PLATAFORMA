#!/usr/bin/env bash
set -euo pipefail
export POSTGRES_PASSWORD="$(openssl rand -hex 24)"
export RUNTIME_PASSWORD="$(openssl rand -hex 24)"
echo "::add-mask::$POSTGRES_PASSWORD"
echo "::add-mask::$RUNTIME_PASSWORD"
echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> "$GITHUB_ENV"
echo "RUNTIME_PASSWORD=$RUNTIME_PASSWORD" >> "$GITHUB_ENV"
echo "DATABASE_URL=postgresql://sgp_owner:$POSTGRES_PASSWORD@127.0.0.1:55433/sgp_test" >> "$GITHUB_ENV"
echo "RUNTIME_DATABASE_URL=postgresql://sgp_runtime:$RUNTIME_PASSWORD@127.0.0.1:55433/sgp_test" >> "$GITHUB_ENV"
docker network create sgp-m0-test
# TEST only; random credentials are generated per run and discarded with the container.
docker run -d --name sgp-m0-test-db --network sgp-m0-test --env POSTGRES_PASSWORD --env POSTGRES_USER=sgp_owner --env POSTGRES_DB=sgp_test -p 127.0.0.1:55433:5432 postgres:17.7-alpine
for attempt in $(seq 1 60); do
  if docker exec sgp-m0-test-db pg_isready -h 127.0.0.1 -U sgp_owner -d sgp_test; then exit 0; fi
  sleep 1
done
exit 1
