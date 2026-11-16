# Independent review — technical candidate f839ad5

Reviewer: independent agent `/root/m1d_publication_review`, GPT-6.1 SOL, high reasoning; read-only review requested by human. Exact candidate: `f839ad5d5500df9fd602512d1ce187c64fa692e6`; base `04081170bca5ac1a062cabc89a3888dbe2760fbe`. PR #1 remains Draft. This records the review of that SHA, not approval of a subsequent commit.

## Open findings

- **HIGH / P1 — denied identity creation is not persisted in audit.** `apps/api/src/auth.ts:193,196–197` and `migrations/005_iam_administration.sql:22`: capability denial throws; scope/delegation denial from create_identity rolls back and the catch returns403 without a separate persistent DENY append. Neither capabilities nor decision writes this event. No password or hash may be added to any future denial evidence. Static finding; no additional mutation performed by reviewer. Master sections22/85/94 and ADC/1 audit/failure contract require recoverable critical-operation audit.
- **HIGH / P1 — mandatory CI failed.** Exact-SHA run43725371145: baseline browser1 FAIL/1 PASS because baseline.spec.mjs:7 expects historical home text; TLS/IAM browser step skipped. This is a stale test expectation, not evidence of an authorization bypass. Human subsequently authorized correcting only that expectation and validating a new SHA.
- **MEDIUM / P2 — denied role-status loses role reference and requested state.** auth.ts:254 forwards target_id, while this request supplies role_id/status. Immutable003 record_rejection records IAM_IDENTITY, actor resource ID, NULL target/states. A denied own-role deactivation cannot be reconstructed by role/state. Static finding; requires separately authorized typed audit remediation, preserving published migrations.

## Evidence and conclusions

VERIFY-001 is supported in its corrected scope: approval metadata is authoritative, actor/session/correlation come from binding, append is DENY-only using existing writer; authentication audit_view is security-invoker with authorized SQL/API access, denial, FORCE RLS and immutable-write tests passing remotely.

Remote4 unit/42 integration PASS, including M1D, VERIFY-001, HIGH-001, maker-checker and audit rollback. Reviewer checked23 downloaded remote files against their hashes without divergence; available local CHECKS report hashes and three source LF hashes match. Semgrep0 findings/0 errors, Gitleaks history/worktree0, npm audit0, Trivy SCA/images0 reported in configured HIGH/CRITICAL scope. Historical and pending evidence is distinguished; no fabricated-evidence finding identified.

The transient local503 cause is unknown. Strict broad audit200 assertion passed locally in final regression and remotely; absence of recurrence does not establish root cause or institutional-volume performance.

Review limits: static code/contracts/diff and existing evidence; no new tests, mutations, edits or approvals. No proven RBAC/ABAC/RLS/SoD bypass identified in reviewed paths; not exhaustive certification. Recommendation: no promotion; re-review the corrected SHA, retain both audit findings until authorized remediation. **M1D_GATE not approved. M2 BLOCKED.**
