# M1C — ABAC e AuthorizationPort

Matriz comum API/SQL; emprego inactivo, estado do sujeito, scope, localização do mesmo grant, versões, metadados ausentes e GUC adulterado. API usa AuthorizationPort no mesmo client/binding; helpers SQL avaliam atributos com clock_timestamp a cada statement. Contexto falso e acção desconhecida negam.

Fonte executável: `tests/integration/authorization.test.mjs`, regressão `tests/integration/authentication.test.mjs` e `tests/auth-browser/identity.spec.mjs`. Fixtures exclusivamente TEST/CI, bases descartadas; zero mocks operacionais.

Resultado local e hashes: CHECKS.json. Resultado remoto e revisão independente: CI.md e atestação final do commit. Nenhum PASS final se CI/revisão estiver pendente.
