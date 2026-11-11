# M1C — Escalada de privilégio

Cada um dos sete executores públicos tem negativos de actor sem capacidade, grant expirado, sessão revogada, CSRF adulterado, cross-scope e SQL directo pelos runtimes. Testes adicionais: own assignment, own clearance, own compartment, own role edit, actor_id no body, forged context/GUC, SET ROLE e DML IAM, audit edit e enrollment privado. Nenhum bypass flag ou executor genérico.

Fonte executável: `tests/integration/authorization.test.mjs`, regressão `tests/integration/authentication.test.mjs` e `tests/auth-browser/identity.spec.mjs`. Fixtures exclusivamente TEST/CI, bases descartadas; zero mocks operacionais.

Resultado local e hashes: CHECKS.json. Resultado remoto e revisão independente: CI.md e atestação final do commit. Nenhum PASS final se CI/revisão estiver pendente.
