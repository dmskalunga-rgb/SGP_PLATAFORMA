# M1D — ASSIGNMENT-TESTS

Reuse assign_role/revoke_assignment; server-side paginated validity reads. Scoped grant preserves permission/assignment/scope binding; self administrative-scope expansion denied. New-user access succeeds then entitlement revocation denies next request.

Proof sources: tests/integration/authorization.test.mjs (two M1D cases and preserved M1C), tests/auth-browser/m1d.spec.mjs; local final log artifacts/m1d-final-local-regression.log. Candidate validation, not a final remote PASS.
