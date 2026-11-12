# M1C-SUB-MEDIUM-001 — fail-closed CI

Candidate fix: both critical workflow pipelines (integration tests and container smoke) now use explicit Bash and `set -o pipefail` before `tee`. Logging is preserved. No business logic or migrations changed.

`scripts/prove-pipefail.sh` proves producer exit 23 -> pipeline 23, success -> 0, and a real intentionally failing Node TEST -> pipeline 1. The ephemeral fixture is created in ignored artifacts and removed by EXIT trap; no broken test is committed. Local Git Bash proof passed. The proof also runs in remote CI and uploads its logs.

`scripts/check-ci-pipelines.mjs`, invoked by `npm run test:policy`, guards the two workflow tee steps against missing explicit Bash/pipefail or failure suppression. Inventory: integration tests and container smoke; proof-script pipelines all execute under pipefail. Local lint and frozen guard PASS.

Finding remains OPEN pending new exact-SHA CI and independent review. M1C_GATE FAIL; M1D/M2 BLOCKED until formal decision.


## Fecho MEDIUM-001 — 2026-11-12

Correcção focal publicada em [0643595](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/0643595faa20422643aa712c104d302f2f743ba1). [CI 43205905235](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43205905235): três jobs PASS, 48/48 testes normais, zero falhas/skips, scanners PASS e quatro SBOM. Provas remotas: producer23/pipeline23, sucesso0, teste Node temporário falhado/pipeline1. Ambos os pipelines críticos usam Bash/pipefail e conservam logs. Business code e migrations intactos.

Re-review independente read-only `/root/medium_final_review`, dispatch GPT-6.1 SOL + Alto, fork sem contexto: oito critérios §14 PASS, sem novos findings CRITICAL/HIGH/MEDIUM/LOW. Provas e limites em MEDIUM-001-CI-FAIL-CLOSED.md. O teste falhado controlado usa node:test temporário, não PostgreSQL; regressão PostgreSQL normal passou. O checker protege o formato actual dos dois steps e não é parser geral YAML/Shell.

Esta decisão substitui os estados FAIL anteriores preservados neste histórico: **M1C-ASTRA-HIGH-001 = CLOSED; M1C-SUB-MEDIUM-001 = CLOSED; INDEPENDENT_REVIEW = PASS; M1C_GATE = PASS; M1D = BLOCKED_PENDING_EXPLICIT_AUTHORIZATION; M2 = BLOCKED.** A atestação exacta com SHA documental/CI encontra-se em refs/notes/m1c-gate. STOP antes de M1D/M2.
