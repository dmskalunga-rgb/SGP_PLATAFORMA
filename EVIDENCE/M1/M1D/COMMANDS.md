# M1D commands and candidate evidence

- Verified HEAD/base 7ee4db8; preserved CHECKS synchronization and DoR. Inventory completed before migration005.
- Build, lint, typecheck, frozen guard and policy passed. Zero operational mocks.
- New PostgreSQL API scenarios 2/2 PASS; browser administration 1/1 PASS.
- Full scripts/local-tests.ps1 final exit0: 4 unit, 40 integration, 2 M0 browser, 5 TLS/IAM browser =51 PASS, no skips/failures. Existing HIGH-001 negative and MEDIUM-001 pipeline policy/proofs preserved.
- Intermediate browser selector failed before mutation; accessible field labels corrected and focal+full E2E passed. Harness now closes pools through a random-token TEST-only shutdown route before ephemeral DB removal, avoiding a teardown connection error observed after a successful focused test.
- Screenshot artifacts/m1d-admin-ui.png inspected: real filter controls, no fabricated data. Raw reports and hashes recorded in CHECKS.json. No credentials or TEST fixture secrets included in tracked evidence.
- New exact-SHA remote CI and independent read-only review remain required before final gate.


Resumption under Master v1.1: last audit_view change validated by 2 focused M1D and 2 affected M1C tests, all PASS. The original 51-test run remains historical evidence for unchanged paths. Automatic approval was retried through the normal approval route; no bypass. First authorized attempt found PostgreSQL TEST stopped; it was started and tests then passed. Unified audit uses security_invoker view with underlying RLS; authentication records have NULL policy/decision IDs where the original event did not define them.


## PR1 controlled remediation and lifecycle checkpoint

- Read-only preflight: c90752e on codex/m1d-iam-administration; empty stage; preserved local remediation; PR1 Draft and main unchanged.
- Focal: node scripts/run-m1c-test.mjs --test --test-concurrency=1 --test-name-pattern="M1D PR1 remediation" tests/integration/authorization.test.mjs =>3PASS.
- Expanded authorization first run24/28; retained broad503 and disabled-fixture401 failures. Corrected new-test fixture only; SGP_TEST_DIAGNOSTICS=1 expanded authorization =>28/28PASS.
- Real TLS session delivery ordering experiment reproduced403invalid_csrf; no mock response or relaxed timeout. Existing M1D browser scenario now asserts disabled actions until real session response, HTTP200/CONSUMED/checker/audit thereafter.
- TEST lifecycle controlled failure deliberately exits1 after real login; separate cleanup proof confirms app.close acknowledgement,0 connections, DROP without FORCE and database absence. Subsequent M1D success and final SQL/resource check pass without fatal teardown. Earlier cycles with teardown errors are historical, not final lifecycle PASS.
- Migration tests2/2PASS; build/lint/typecheck/frozen/policyPASS; production dependency SBOM generated; current security results and report hashes in CHECKS.
- Published001-005, Masters and FROZEN contracts unchanged. Exact-SHA CI and independent final review remain required before gate review. No self-approval or merge.
