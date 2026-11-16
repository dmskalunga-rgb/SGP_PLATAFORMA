# M1D — SESSION-ADMIN-TESTS

Read sanitized sessions (no token/hash); revoke one/all through account_command. API and browser prove subsequent session request401. Existing M1B linearization/deadline tests preserved.

Proof sources: tests/integration/authorization.test.mjs (two M1D cases and preserved M1C), tests/auth-browser/m1d.spec.mjs; local final log artifacts/m1d-final-local-regression.log. Candidate validation, not a final remote PASS.
