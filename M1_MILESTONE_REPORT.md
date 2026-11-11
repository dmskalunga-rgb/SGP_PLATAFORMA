# M1 — checkpoint M1B

M1B — IDENTITY & SESSION FOUNDATION implementado para revisão de gate. Decisão final só após commit/push e CI remota exacta: [CI](EVIDENCE/M1/M1B/CI.md), [matriz](EVIDENCE/M1/M1B/M1B-GATE.md), [checks](EVIDENCE/M1/M1B/CHECKS.json). M1 completo não está concluído; M1C/M1D/M2 não estão autorizados. Não se declara PRODUCTION_READY.

Base M1A: [58834d8](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/58834d8edb3c4b07c2fc9b68c0900886e0e8d12c), publicação/ASTRA/freeze preservados em EVIDENCE/M1/M1A. Master e onze contratos/ADRs exactos. O operador autorizou explicitamente somente o RLS interno mínimo exigido pelo M1A; nenhum contrato FROZEN foi alterado.

Entrega: migration002 identities/credentials/sessions/metadados IAM e auth events; logins app/auth separados, owners NOLOGIN, sem DML runtime; comandos DB tipados e audit atómico; Argon2id calibrado; nonce/CSRF/login, expiração/revogação/rotação/logout/password change; contexto request isolado; bootstrap vazio de duas identidades reais por stdin protegido; lifecycle e comandos mínimos de conta/sessão; páginas reais login/logout/session-expired/access-denied/profile; gateway TLS parametrizável, schemas/OpenAPI e CI ampliada com regressão M0.

Sem motor de autorização de negócio, administração de entitlements, árvore organizacional ou património. Grants iniciais são capacidades técnicas mínimas, sem clearance/compartimentos. Sem reset remoto/backdoor ou utilizadores seed fictícios. Autenticação HTTP é recusada e falhas de autoridade/audit fecham operação.

Local: 4 unit,17 integração/API/DB,2 browser M0,3 TLS browser M1B PASS, zero fail/skip/flaky. Testes adversariais GUC/SQL, concorrência/revogação, timeout15s, audit rollback e logs reais sanitizados. Npm audit zero vulnerabilidades e secret scan zero findings; CI remota/scans são pré-condição do gate. Ver relatórios de testes/segurança e evidência.

Modelos: sessão principal sem nova revisão ASTRA alegada; revisão M1A preservada. Routing/consumo exacto não inventados. Após gate final: STOP, M1C só com nova autorização explícita.
