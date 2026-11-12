# M1C-ASTRA-HIGH-001 — temporal clearance elevation

Status: corrected locally in candidate migration 004; closure still requires new published SHA, full remote CI and independent ASTRA re-review. The original HIGH finding remains OPEN until those gates pass.

ASTRA reproduced the pre-fix flaw on the published technical commit [cca2b2b](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/cca2b2b4ce9605b9344099b59d17ea70fac63160): API 200, a bounded clearance became unbounded, zero approvals. Its exact reported proof is in ASTRA-REVIEW.md. The reviewer stopped at that HIGH as instructed; the remaining M1C review has not been completed.

Migration `004_clearance_temporal_approval_hardening.sql` preserves checksums of migrations 001–003. `clearance_is_elevation` compares the proposed `[valid_from, valid_to)` interval against the union of existing active clearances at the same or higher rank. PostgreSQL `NULL` upper bounds mean unbounded validity. Any uncovered portion, including a later finite end, an earlier start or a higher rank, requires the existing distinct maker/checker path. A contained interval is a reduction and remains subject to authorization, locks, versioning and audit.

For a clearance approval, the database stores and hashes the target, exact previous row, proposed classification/rank/window and current policy version. Execution recomputes that object under the existing exclusive policy lock. The existing approval executor checks maker/checker identity, session, live authority, delegation ceiling, policy version and one-time consumption. The success event includes before/after, approval, maker/checker and decision ID. A denial event uses the established post-rollback channel and includes the typed requested change, actor, target, reason, request/correlation IDs and policy version.

Focused PostgreSQL TEST proof on the candidate:

| Case | Result |
|---|---|
| finite → unbounded without approval, API | DENY; interval/version unchanged; denial audited |
| finite → unbounded with exact approval | ALLOW; consumed once; before/after and versions audited |
| finite → later finite, without / with approval | DENY / ALLOW |
| finite → earlier finite | ALLOW as authorized reduction |
| higher rank and longer validity | DENY without approval; ALLOW with approval |
| actor = target; maker = checker | DENY |
| changed execution payload or changed old row | DENY |
| maker or checker authority expired; stale policy | DENY |
| consumed approval replay, even if state matches | DENY |
| two concurrent executions of the same approval | one ALLOW, one DENY |
| earlier `valid_from` expanding the interval | DENY without approval |
| direct runtime SQL DML | DENY for app_runtime and auth_runtime |
| direct typed SQL executor without approval | DENY |

The focused run passed 2/2 tests. Full local regression passed 4 unit, 38 integration, 2 M0 browser and 4 TLS browser = **48/48**, zero failures/skips, using real disposable PostgreSQL. `npm run build`, `npm run typecheck`, `npm run lint`, `npm run test:policy` and the Master/M1A frozen guard also passed. Local Semgrep found zero findings/errors, npm audit zero vulnerabilities, and Gitleaks found zero worktree secrets. New SHA remote scans, CI and ASTRA re-review remain separate gates; no PASS is inferred from local tests.

Publication update: the fix is published as [161e246](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/161e246614fb3da8cc3c950f9ed5cf0c42cc301e). Remote [run 43167843976](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43167843976) passed all three jobs, 48 tests, zero SAST/secrets/npm audit/Trivy HIGH-CRITICAL results, and produced four SBOMs. The required ASTRA re-review of this SHA was rejected by automatic cybersecurity review before execution. Therefore finding closure is **OPEN**, `M1C_GATE = FAIL`, M1D/M2 BLOCKED.

Independent substitute review under `CR-M1C-REVIEW-001` confirmed H1-01–17 PASS and the original temporal vulnerability FIXED on the exact technical SHA. Its expanded 40-point assessment found `M1C-SUB-MEDIUM-001` in CI failure propagation, which blocks the M1C gate. The substitute's initial focal PASS was superseded by its final FAIL addendum. HIGH-001 remains OPEN for governance under CR §17; see `INDEPENDENT-REVIEW-H1.md`.
