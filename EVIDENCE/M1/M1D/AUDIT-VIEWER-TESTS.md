# M1D — AUDIT-VIEWER-TESTS

Server-side pagination and actor/target/action/result/from/to/request/correlation filters operate under RLS. API test checks target/action/result filter, total and request/correlation/decision fields. Viewer has no write/remove operation; direct DELETE denied. Audit writer failure rolls privileged change back.

Proof sources: tests/integration/authorization.test.mjs (two M1D cases and preserved M1C), tests/auth-browser/m1d.spec.mjs; local final log artifacts/m1d-final-local-regression.log. Candidate validation, not a final remote PASS.


Resumption under Master v1.1: last audit_view change validated by 2 focused M1D and 2 affected M1C tests, all PASS. The original 51-test run remains historical evidence for unchanged paths. Automatic approval was retried through the normal approval route; no bypass. First authorized attempt found PostgreSQL TEST stopped; it was started and tests then passed. Unified audit uses security_invoker view with underlying RLS; authentication records have NULL policy/decision IDs where the original event did not define them.


## M1D-VERIFY-001 local remediation

Denied execution/rejection now derives action, target and approval reference from the stored approval, and actor/session/correlation from binding, using the existing immutable writer. Migration005 only; 001–004 preserved. Focal2/2 and affected authorization regression25/25 PASS; historical51-test proof was not rerun. Authentication audit_view authorized/unauthorized SQL and API, FORCE RLS and write denial verified. Intermediate broad audit query503 is retained in evidence; final strict broad and exact-event assertions passed without timeout changes. See EVIDENCE/M1/M1D/VERIFY-001-AUDIT-REMEDIATION.md and CHECKS.json. No publication or final M1D gate approval is claimed; M2 BLOCKED.
