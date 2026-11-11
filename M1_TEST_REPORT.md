# M1 — testes M1B

[LOCAL-TESTS](EVIDENCE/M1/M1B/LOCAL-TESTS.json), [browser TLS](EVIDENCE/M1/M1B/BROWSER-E2E.json), [auth](EVIDENCE/M1/M1B/AUTH-TESTS.md), [sessões](EVIDENCE/M1/M1B/SESSION-TESTS.md). Suite integral local: 4 unit+17 integração/API/DB+2 browser M0+3 TLS browser M1B =26 PASS, zero fail/skip/flaky. Após revalidação temporal de grants, três comandos afectados repetidos PASS; CI deve repetir tudo no SHA final.

Unit: config fail-closed, Argon2id/salts/metadata/NFC/limites e frozen guard positivo/negativo em cópia isolada. Integração preserva migration repeat/checksum/DDL rollback/readiness/outage M0, agora com DBs TEST distintos para schemas de segurança qualificados.

M1B: login positivo/negativo/unknown/status, schemas/Origin/CSRF, nonce replay/rate budget, lockout/desbloqueio, expiry absoluta/idle, token inválido, logout duplo/replay, rotação/revogação one/all/password, sessões simultâneas, requests A/B e poolmax1, SQL/GUC/SET ROLE deny, FORCE RLS interno, audit failure rollback, bootstrap replay/runtime deny, lifecycle/autoria/self/últimos operadores, revogação concorrente e transaction_timeout15s real libertando locks. Logs serializados e respostas não contêm segredos efémeros.

Browser: bootstrap CLI real, login TLS, sessão persistida, logout/replay; operador revoga outra sessão/retry redirecciona; falhas repetidas/lock e eventos reconstruíveis. Sem interceptação mock de rede/banco. Corridas React StrictMode/nonce e janela de rate limit na fronteira do minuto corrigidas antes da publicação, sem aceitar retries/flaky.

Build/lint/typecheck/frozen guard e npm audit locais PASS. CI mantém três jobs M0 e adiciona IAM/calibração/TLS E2E. SAST/SCA/segredos/imagens/SBOM obrigatórios no SHA exacto; resultado final em [CI](EVIDENCE/M1/M1B/CI.md) e nota Git pós-CI. Testes de classificação/compartimentos/RLS de negócio e UI admin completa pertencem M1C/D, não são resultados M1B.
