# M0-R1 — evidência de testes

Estado final validado: oito testes PASS localmente e no run remoto 43006790217, mais smoke de containers PASS. Não há skip, flaky ou retry mascarando falha de browser no run aceite.

2 testes unitários validam configuração fail-closed. 4 testes de integração usam PostgreSQL real e validam persistência, repetição idempotente, checksum, rollback deliberado de DDL/tracking, schema ausente, ready/live, limites/headers e sanitização. 2 testes reais de browser validam render/API/PostgreSQL e outage/retry sem mocks. O runtime técnico do banco tem superuser/createdb/createrole/bypassrls=false.

O teste final local usou Chrome instalado; CI usou Chromium com Node 24.22.2. A suite local final com sgp-postgres:m0 passou após terminar os scans pesados; os resultados de diagnóstico anteriores não são reutilizados como se fossem o estado final. O smoke final local e remoto verificou UID 70/1000/101, readonly, no-new-privileges, cap-drop, ausência de npm/TypeScript/Vite/ESLint no API runtime, healthchecks e DB parado produzindo 503 sem derrubar live.

Reprodução: npm ci, npm run build/lint/typecheck, scripts/local-tests.ps1, scripts/container-smoke.sh e workflow versionado. Evidência remota copiada em M0-R1/frontend-summary.json, container-smoke.log, container-runtime.log e metadata original guardada em artifacts/closure-preserved/ci-run.json e nos logs do run; logs locais detalhados em artifacts/.
