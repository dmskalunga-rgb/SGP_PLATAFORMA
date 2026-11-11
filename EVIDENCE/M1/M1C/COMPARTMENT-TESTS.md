# M1C — Compartimentos

Acesso requer todos os compartimentos; A não permite A+B. Testes cobrem concessão real, membro em falta, compartimento inactivo, sensibilidade com maker-checker e replay. A aprovação revalida também membership do maker depois de uma expiração temporal. Metadados incompletos não significam conjunto vazio público.

Fonte executável: `tests/integration/authorization.test.mjs`, regressão `tests/integration/authentication.test.mjs` e `tests/auth-browser/identity.spec.mjs`. Fixtures exclusivamente TEST/CI, bases descartadas; zero mocks operacionais.

Resultado local e hashes: CHECKS.json. Resultado remoto e revisão independente: CI.md e atestação final do commit. Nenhum PASS final se CI/revisão estiver pendente.
