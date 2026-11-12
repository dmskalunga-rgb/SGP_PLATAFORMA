# M1C — independent ASTRA review

Reviewed technical commit: `cca2b2b4ce9605b9344099b59d17ea70fac63160`.
Reviewed CI run: `43093293944` (all three jobs successful).
Reviewed authority: M1C authorization and M1A FROZEN security contracts.

## Finding M1C-ASTRA-HIGH-001 — OPEN

- Severity: HIGH.
- Component: `iam.grant_clearance` in `migrations/003_authorization.sql`.
- Evidence: ASTRA used the real API and an ephemeral PostgreSQL TEST database. A bounded clearance at the same rank was changed to `valid_to = NULL` with `approval_id = NULL`. The API returned 200, and the database changed from bounded to unbounded validity. The focused result reported by ASTRA was `{"proof":"ASTRA-CLEARANCE-TEMPORAL","http":200,"beforeBounded":true,"afterUnbounded":true,"approvals":0}`.
- Security impact: one operator can extend the target's temporal clearance beyond its authorized expiry without a second operator.
- Required remediation: treat expansion of effective clearance validity as privileged, bind the exact old and proposed authority to approval, and revalidate under the policy lock.
- Gate impact: `M1C_GATE = FAIL` while open. M1D and M2 remain blocked.

ASTRA stopped the review at the first confirmed HIGH as required by the review order. Its workspace then ran out of credits before it could finish and write its own report. This file records the finding and proof communicated by the independent reviewer; it does **not** claim a complete ASTRA review or PASS. A separate suspicion about `set_role_permission` was not confirmed and is not counted as a finding. A new review of the corrected SHA and remaining boundaries is required.
