# M1D — PRIVILEGE-ESCALATION

M1C direct SQL, owners, GUC, binding, SoD, delegation and maker-checker tests preserved. M1D adds own-role, self attribute/revoke, self scope expansion, caller actor claim, unauthorized API, approvals/audit denial and direct DML checks. Runtime ownership/flags unchanged.

Proof sources: tests/integration/authorization.test.mjs (two M1D cases and preserved M1C), tests/auth-browser/m1d.spec.mjs; local final log artifacts/m1d-final-local-regression.log. Candidate validation, not a final remote PASS.
