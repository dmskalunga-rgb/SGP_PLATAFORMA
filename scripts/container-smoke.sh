#!/usr/bin/env bash
set -euo pipefail
export MSYS_NO_PATHCONV=1
mkdir -p artifacts
network="sgp-smoke-$RANDOM"
db="sgp-db-$RANDOM"
api="sgp-api-$RANDOM"
web="sgp-web-$RANDOM"
cleanup() {
  docker rm -f "$web" "$api" "$db" >/dev/null 2>&1 || :
  docker network rm "$network" >/dev/null 2>&1 || :
}
trap cleanup EXIT
export NODE_ENV=test
export POSTGRES_PASSWORD="$(openssl rand -hex 24)"
export RUNTIME_PASSWORD="$(openssl rand -hex 24)"
if [ "${GITHUB_ACTIONS:-}" = true ]; then
  echo "::add-mask::$POSTGRES_PASSWORD"
  echo "::add-mask::$RUNTIME_PASSWORD"
fi
docker network create "$network" >/dev/null
docker run -d --name "$db" --network "$network" --user postgres --cap-drop ALL --security-opt no-new-privileges:true --read-only --tmpfs /tmp --tmpfs /var/run/postgresql --env POSTGRES_PASSWORD --env POSTGRES_USER=sgp_owner --env POSTGRES_DB=sgp_test -p 127.0.0.1:55434:5432 postgres:17-alpine@sha256:3540c0362c809df084ffac0ae69fe794515f9de92692f02178bcdce0ef0302ac >/dev/null
for attempt in $(seq 1 60); do
  if docker exec "$db" pg_isready -h 127.0.0.1 -U sgp_owner -d sgp_test >/dev/null 2>&1; then break; fi
  sleep 1
done
export DATABASE_URL="postgresql://sgp_owner:$POSTGRES_PASSWORD@127.0.0.1:55434/sgp_test"
node scripts/migrate.mjs
node scripts/provision-test-runtime.mjs
export DATABASE_URL="postgresql://sgp_runtime:$RUNTIME_PASSWORD@$db:5432/sgp_test"
docker run -d --name "$api" --network "$network" --env DATABASE_URL --cap-drop ALL --security-opt no-new-privileges:true --read-only --memory 256m --cpus 1 --pids-limit 64 -p 127.0.0.1:3300:3000 sgp-api:m0 >/dev/null
export API_UPSTREAM="http://$api:3000"
docker run -d --name "$web" --network "$network" --env API_UPSTREAM --cap-drop ALL --security-opt no-new-privileges:true --read-only --tmpfs /tmp --memory 128m --cpus .5 --pids-limit 64 -p 127.0.0.1:8180:8080 sgp-web:m0 >/dev/null
for attempt in $(seq 1 60); do
  if curl --fail --silent http://127.0.0.1:8180/health/ready > artifacts/container-ready.json; then break; fi
  sleep 1
done
curl --fail --silent http://127.0.0.1:3300/health/live
curl --fail --silent http://127.0.0.1:8180/ > artifacts/container-web.html
curl --fail --silent http://127.0.0.1:8180/health/ready
for name in "$db" "$api" "$web"; do
  uid="$(docker exec "$name" id -u)"
  test "$uid" -gt 0
  echo "$name runtime uid=$uid"
  docker inspect "$name" --format '{{.Config.User}} readOnly={{.HostConfig.ReadonlyRootfs}} caps={{json .HostConfig.CapDrop}} security={{json .HostConfig.SecurityOpt}}' >> artifacts/container-runtime.log
done
if docker exec "$api" touch /app/write-must-fail 2>/dev/null; then echo 'Read-only invariant violated'; exit 1; fi
docker exec "$api" node -e "for(const p of ['typescript','vite','eslint']){try{require.resolve(p);process.exit(1)}catch{}}"
if docker exec "$api" sh -c 'command -v npm'; then echo 'Unexpected npm runtime';exit 1;fi
for attempt in $(seq 1 40); do
  if [ "$(docker inspect "$api" --format '{{.State.Health.Status}}')" = healthy ] && [ "$(docker inspect "$web" --format '{{.State.Health.Status}}')" = healthy ]; then break; fi
  sleep 1
done
test "$(docker inspect "$api" --format '{{.State.Health.Status}}')" = healthy
test "$(docker inspect "$web" --format '{{.State.Health.Status}}')" = healthy
docker stop "$db" >/dev/null
status="$(curl --silent -o artifacts/container-ready-unavailable.json -w '%{http_code}' http://127.0.0.1:3300/health/ready)"
test "$status" = 503
curl --fail --silent http://127.0.0.1:3300/health/live
echo 'Container security and real database outage checks PASS'
