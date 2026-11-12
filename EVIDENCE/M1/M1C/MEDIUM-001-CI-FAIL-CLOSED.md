# M1C-SUB-MEDIUM-001 — fail-closed CI

Candidate fix: both critical workflow pipelines (integration tests and container smoke) now use explicit Bash and `set -o pipefail` before `tee`. Logging is preserved. No business logic or migrations changed.

`scripts/prove-pipefail.sh` proves producer exit 23 -> pipeline 23, success -> 0, and a real intentionally failing Node TEST -> pipeline 1. The ephemeral fixture is created in ignored artifacts and removed by EXIT trap; no broken test is committed. Local Git Bash proof passed. The proof also runs in remote CI and uploads its logs.

`scripts/check-ci-pipelines.mjs`, invoked by `npm run test:policy`, guards the two workflow tee steps against missing explicit Bash/pipefail or failure suppression. Inventory: integration tests and container smoke; proof-script pipelines all execute under pipefail. Local lint and frozen guard PASS.

Finding remains OPEN pending new exact-SHA CI and independent review. M1C_GATE FAIL; M1D/M2 BLOCKED until formal decision.
