# M1D — USER-ADMIN-TESTS

Create INACTIVE identity with explicit scope/classification and real password hash; activate through existing account_command; real new-user login. Details separate identity/account/roles/scopes/clearance/compartments/sessions/events. Unauthorized creation and caller actor fields denied. Audit failure rolls creation back.

Proof sources: tests/integration/authorization.test.mjs (two M1D cases and preserved M1C), tests/auth-browser/m1d.spec.mjs; local final log artifacts/m1d-final-local-regression.log. Candidate validation, not a final remote PASS.
