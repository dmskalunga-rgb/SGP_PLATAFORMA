# M1D — APPROVAL-TESTS

Inbox protected by RLS and operation-specific target authorization. Stored payload dispatch calls existing typed executor without binding twice. Maker execution denied, checker succeeds, replay denied; rejection preserves entitlement and logs actor/reason. PENDING/CONSUMED/REJECTED plus derived EXPIRED states.

Proof sources: tests/integration/authorization.test.mjs (two M1D cases and preserved M1C), tests/auth-browser/m1d.spec.mjs; local final log artifacts/m1d-final-local-regression.log. Candidate validation, not a final remote PASS.


## M1D-VERIFY-001 local remediation

Denied execution/rejection now derives action, target and approval reference from the stored approval, and actor/session/correlation from binding, using the existing immutable writer. Migration005 only; 001–004 preserved. Focal2/2 and affected authorization regression25/25 PASS; historical51-test proof was not rerun. Authentication audit_view authorized/unauthorized SQL and API, FORCE RLS and write denial verified. Intermediate broad audit query503 is retained in evidence; final strict broad and exact-event assertions passed without timeout changes. See EVIDENCE/M1/M1D/VERIFY-001-AUDIT-REMEDIATION.md and CHECKS.json. No publication or final M1D gate approval is claimed; M2 BLOCKED.
