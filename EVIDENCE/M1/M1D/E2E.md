# M1D — E2E

API M1D: create->activate->role->approval->attributes->new login->allowed/forbidden->entitlement/session revocation->audit. TLS browser M1D drives real forms, maker refusal, second operator inbox/approve, new-user access, revocation and filtered audit. No operational mocks. Browser screenshot artifacts/m1d-admin-ui.png. Temporary harness shutdown endpoint exists only in TEST server script and requires random fixture token before pool/database cleanup.

Proof sources: tests/integration/authorization.test.mjs (two M1D cases and preserved M1C), tests/auth-browser/m1d.spec.mjs; local final log artifacts/m1d-final-local-regression.log. Candidate validation, not a final remote PASS.
