# M1D-VERIFY-001 — remediation evidence

## Root cause

The new API paths approval-executions and approval-rejections called the M1C generic record_rejection channel as operation approvals with target_id NULL. That legacy channel maps approvals to security.assignments.manage and cannot receive the approval ID. The failed transaction rolls back its own events; the later generic event therefore lost the real action, target and approval reference. Migration003 is historical and was not changed.

## Correction

Migration005 adds record_approval_rejection: closed route catalogue, verified binding for actor/session/request/correlation, authoritative approval lookup for operation/target, and the existing record_decision writer. It can append only DENY. Known roles/clearance/compartment approvals retain their actual permission action, resource kind, target and approval ID; requested execution versus rejection is distinguished. No credentials, full payload or rejection free text are copied into the denial event. Reason remains COMMAND_REJECTED rather than guessing a more specific cause.

For an absent approval, actual approval/target are NULL; only the supplied request reference and route are recorded. No target or permission action is fabricated. Events lacking authorized resource metadata remain hidden by runtime RLS and are retained for privileged audit inspection.

The API uses this adapter only for the two affected paths, after rollback. The original denial channel and migrations001–004 remain unchanged. No second audit infrastructure, RLS bypass or changed timeout was introduced.

## Executed proof

- Focal PostgreSQL run: 2 tests PASS, 0 fail/skipped (artifacts/m1d-verify-001-focal.log).
- Six API denials cover execution/rejection across ROLE_GRANT, CLEARANCE_GRANT and COMPARTMENT_GRANT. All remain403; persisted events retain correct action/resource type, actor/session, target, approval ID, timestamp, request/correlation and decision. An authorized audit API query retrieves them. Approval remains PENDING.
- Unknown approval retains NULL actual identity/target and the supplied reference only.
- authentication_events audit_view branch: authorized SQL and API reads succeed; unauthorized SQL returns zero rows and unauthorized API returns403. View DELETE denied, underlying RLS/FORCE RLS retained and security_invoker verified.
- Affected authorization regression: final25/25 PASS, zero failures/skips, including existing M1C, HIGH-001, maker-checker and audit rollback. No M0/browser restart was necessary; prior51-test proof remains historical.
- Intermediate expanded run24/25: broad audit target query returned503. Final verification retained the broad-query200 requirement and additionally queried the exact authentication request ID to avoid depending on first-page order. Final25/25 passed without changing production query logic or timeouts. The cause of the intermediate503 is not established; preserve both logs and monitor audit latency in CI/review.

Logs: artifacts/m1d-verify-001-authorization-regression.log (intermediate) and artifacts/m1d-verify-001-authorization-regression-final.log (final). Hashes and current SAST reference are in CHECKS.json.

Status: locally remediated with executed evidence; M1D gate, remote CI and independent review remain pending. No commit/push in this phase. M2 BLOCKED.

Final local checks: build/lint/typecheck/frozen guard/policy PASS. Updated SAST current report19 files, zero findings/errors; secret scan zero findings. Source LF hashes and all new report hashes are recorded in CHECKS.json. Decision READY_FOR_TECHNICAL_COMMIT, with CI and independent review still required for M1D_GATE.
