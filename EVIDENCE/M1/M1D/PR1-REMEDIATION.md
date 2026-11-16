# M1D PR1 controlled remediation

Scope: resume the existing Draft PR1 candidate on codex/m1d-iam-administration. Parent checkpoint c90752e. No merge, production deployment, M1D_GATE PASS, M2 or CR-SGP-002 authorization. Masters, FROZEN contracts, passed gates and published migrations001–005 preserved.

## Finding matrix

| Finding | Confirmed cause | Correction | Local evidence / state |
|---|---|---|---|
| HIGH identity DENY audit | Capability throw and typed DB rollback had no persistent denial append | Typed DENY-only adapter in006, API post-rollback channel; NULL absent IDs; no sensitive input | Focal3/3 and affected28/28 PASS; publication review pending |
| MEDIUM role-status | Generic adapter read target_id although body supplied role_id/status; historical writer labelled actor identity | Typed role adapter, stored role snapshot and requested status/reference | Permission, scope/RLS, self-protection, SoD, unknown role and rollback coverage; locally validated |
| HIGH TLS checker | Reproduced race: list ready before session/CSRF; empty-CSRF POST403 invalid_csrf; approval PENDING, sessions live | Disable approval/rejection before CSRF, handler guard; real-response-order regression | Cycles3/4 PASS; final lifecycle run PASS; HTTP200, CONSUMED/checker/audit checked |
| Secret scan and24 notes findings |23 note values are verified public Git commit objects; one is SBOM report SHA256; intermediate public candidate ID also matched | Individual proof, exact values under respective existing rules only | Historical triage JSON; all-refs scan zero; final worktree/history scans tracked in CHECKS |
| TEST teardown | HTTP listener stopped before pool onClose hooks completed; prior cleanup could drop active DB | Nonce/database-bound acknowledgement after app.close, explicit zero connections, DROP without FORCE, absence check | Deliberate test failure exit1 is expected control, not business PASS; cleanup succeeds. Final successful TLS also proves cleanup |
| Broad audit503 | Intermittent observation, cause unconfirmed | SQLSTATE-only diagnostics; no timeout/retry relaxation, no broad-query assertion removal | OPEN INVESTIGATION; initial expanded run failed; next strict28/28 run passed |

## Preserved chronology

- Historical51/53-test suites and previous CI/reviews remain historical, not substituted for this candidate.
- Initial new focal audit tests3/3 PASS in real disposable PostgreSQL.
- First expanded authorization run24/28 PASS: broad audit query503 plus three new-test401 failures caused by reusing a fixture intentionally disabled by an earlier M1C test. New tests now use the existing active unprivileged fixture; no application bypass or restoration of the deliberately disabled identity.
- Diagnostic expanded authorization28/28 PASS, zero skipped/cancelled. The original failed log remains preserved. Expected injected audit failures remain503; this does not close the unexplained broad-query503 observation.
- TLS cycles1/2 business assertions passed but fatal teardown errors occurred; these are not final lifecycle PASS evidence.
- TLS cycles3/4 passed after acknowledgement fix, without fatal teardown errors.
- Final lifecycle failure-control deliberately fails after real login, exit1; separately verifies close acknowledgement,0 connections before DROP, no FORCE and DB absence. The subsequent real M1D success run also passes those checks.
- Migration regression2/2 PASS:001–006 apply, repeat preserves tracking, checksum drift denied and deliberate DDL failure rolled back.

## Evidence semantics and limits

See CHECKS.json for report/source hashes and final local checks. Ignored artifacts retain raw reports, sanitized lifecycle/HTTP/state evidence and diagnostics; no fixture credentials are tracked. The diagnostic session-delivery barrier controls timing only and forwards every response to the real API. It uses no fabricated API response, database substitute, retry or longer timeout. Historical PR failure lacked HTTP detail; the local pre-fix experiment proves the initialization defect without inventing historical server responses.

The creation-denial policy uses proposed scope/classification for an object never created; no invented identity ID routes access. The role before-state is the authoritative post-rollback snapshot at append time. Security details and direct SQL limitations are documented in docs/operations/M1D-DENIAL-AUDIT.md.

Publication, new exact-SHA direct CI, PR merge-synthetic CI and independent final review remain separate required steps. This document does not self-approve a gate.
