# M1 — rastreabilidade M1B

Desenho: contratos FROZEN/ADR007–010 exactos. DoR: docs/requirements/M1B-PLAN.md. Evidência: EVIDENCE/M1/M1B/{CHECKS.json,LOCAL-TESTS.json,M1B-GATE.md,CI.md}.

| Requisito | Código/migration/API | Teste/evidência |
|---|---|---|
| SGP-IAM-001 identity/lifecycle | 002 users/credentials; auth.ts; account-command | authentication.test.mjs lifecycle/status/self/últimos operadores; AUTH-TESTS |
| SGP-IAM-002 password | password.ts; credentials; bootstrap CLI/change-password | password.test.mjs; PASSWORD-HASHING/ARGON2-CALIBRATION |
| SGP-SES-001 sessões/revogação | sessions/bind/login/logout/rotate/change_password/account_command | expiry/replay/rotation/all/concurrency/deadline; SESSION-TESTS |
| SGP-CTX-001/002 contexto | request.auth immutable; binding/SET LOCAL/finish; app/auth pools | A/B/poolmax1/GUC/rollback/rebind |
| SGP-AUD-001 audit | authentication_events/event + transacções | audit rollback/log capture/browser sequência; AUDIT-EVIDENCE |
| SGP-BOOT-001 bootstrap | stdin privado; bootstrap empty-only/dois operadores | replay/runtime deny, CLI real browser; BOOTSTRAP |
| SGP-SEC-001 TLS/CSRF/rate | auth.ts/nonce/rate_buckets/gateway/ViteTLS | schemas/Origin/nonce/rate/flags/lockout |
| SGP-FE-001 frontend real | AuthPages login/logout/expired/denied/profile | 3 TLS browser E2E, backend/DB reais |
| SGP-GOV-001 integridade/regressão | frozen guard pinado/ci.yml/helpers DB isolado | cópia adulterada recusada; M0 suites/CI |
| SGP-RLS-001 interno mínimo | 002 FORCE/privileges/NOLOGIN/commands | SQL app/auth deny; flags; sem RLS de negócio |

RBAC/ABAC/CLS/CMP/SoD completos continuam em desenho, sem motor/admin UI desta subfase. Metadados de suporte existem conforme M1B; não autorizam M1C. Migrations001+002 e OpenAPI de endpoints reais; sem M2.
