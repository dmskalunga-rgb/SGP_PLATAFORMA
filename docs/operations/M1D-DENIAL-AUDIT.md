# M1D denial audit remediation

Migration006 extends the published001–005 baseline. It uses the existing request binding, record_decision writer, append-only authorization_events and security-invoker audit_view. No new audit store or operational fixture is introduced.

Identity creation: the API catches capability and typed DB authorization denials after rollback, then invokes record_identity_creation_rejection in a new transaction. The function derives actor/session/correlation from binding, evaluates requested scope/classification, and appends DENY only. It accepts no username, name, password, hash, actor, session or result parameter. A rejected creation has no existing resource/target ID: both remain NULL. Proposed scope/classification are labelled as request input. The additional SELECT policy applies only to these creation DENYs and evaluates security.audit.read against that proposed scope/classification; unknown metadata and unbound/unauthorized readers fail closed.

Role state: record_role_status_rejection resolves the real role and current status after rollback, retaining the requested role/status separately. It records IAM_ROLE/security.roles.manage; a role is not an IAM identity. An absent role is never invented. The before-state is the authoritative post-rollback snapshot at append time, not a claim that concurrent history was locked across two separate transactions. Permission/scope/SoD/delegation/self-protection reasons are retained when available; other command failures remain COMMAND_REJECTED. Runtime callers cannot choose an ALLOW result or audit actor.

Append failure propagates as sanitized503. No protected mutation survives a failed success append; denied commands also have no business effects if the separate denial append fails. Untrusted direct SQL still cannot mutate IAM or write events; rejected SQL transactions require the same separate audit channel, as in the existing contract. No autonomous parallel audit infrastructure is claimed.

TLS diagnosis reproduced a UI initialization race: approval rows appeared before session/CSRF delivery, allowing an empty-CSRF POST (403 invalid_csrf, approval still PENDING). Approval/rejection buttons now remain disabled until CSRF is ready; the mutation handler also checks readiness. Server CSRF, maker-checker and RLS rules are unchanged. The browser regression controls delivery order of the real session response, without fabricated responses, increased timeouts or mutation retries, and records sanitized HTTP/approval/audit evidence.

TEST teardown waits for a database/nonce-bound acknowledgement written only after app.close() resolves. It measures zero database connections, drops without FORCE and verifies database absence. This is TEST-only lifecycle control, with no production route or fixture changes.

The intermittent broad audit503 remains under investigation. Existing statement/lock/transaction limits and strict200 assertions are unchanged. SQLSTATE-only technical diagnostics contain no SQL parameters or credentials. Historical failed runs remain evidence and are not counted as final PASS.

M1D_GATE is not approved by this document. M2 remains BLOCKED. No merge or production deployment is authorized.
