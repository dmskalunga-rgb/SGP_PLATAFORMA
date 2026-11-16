# M1D — COMPARTMENT-ADMIN-TESTS

Read catalogue and memberships under existing RLS, grant via approved primitive, revoke through typed executor. Self mutation denied, sensitive-compartment maker-checker regressions preserved.

Proof sources: tests/integration/authorization.test.mjs (two M1D cases and preserved M1C), tests/auth-browser/m1d.spec.mjs; local final log artifacts/m1d-final-local-regression.log. Candidate validation, not a final remote PASS.
