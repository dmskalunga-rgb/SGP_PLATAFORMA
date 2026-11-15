# M1D commands and candidate evidence

- Verified HEAD/base 7ee4db8; preserved CHECKS synchronization and DoR. Inventory completed before migration005.
- Build, lint, typecheck, frozen guard and policy passed. Zero operational mocks.
- New PostgreSQL API scenarios 2/2 PASS; browser administration 1/1 PASS.
- Full scripts/local-tests.ps1 final exit0: 4 unit, 40 integration, 2 M0 browser, 5 TLS/IAM browser =51 PASS, no skips/failures. Existing HIGH-001 negative and MEDIUM-001 pipeline policy/proofs preserved.
- Intermediate browser selector failed before mutation; accessible field labels corrected and focal+full E2E passed. Harness now closes pools through a random-token TEST-only shutdown route before ephemeral DB removal, avoiding a teardown connection error observed after a successful focused test.
- Screenshot artifacts/m1d-admin-ui.png inspected: real filter controls, no fabricated data. Raw reports and hashes recorded in CHECKS.json. No credentials or TEST fixture secrets included in tracked evidence.
- New exact-SHA remote CI and independent read-only review remain required before final gate.


Resumption under Master v1.1: last audit_view change validated by 2 focused M1D and 2 affected M1C tests, all PASS. The original 51-test run remains historical evidence for unchanged paths. Automatic approval was retried through the normal approval route; no bypass. First authorized attempt found PostgreSQL TEST stopped; it was started and tests then passed. Unified audit uses security_invoker view with underlying RLS; authentication records have NULL policy/decision IDs where the original event did not define them.
