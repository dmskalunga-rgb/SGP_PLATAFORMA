# M1C — Classificação e clearance

Todos os cinco limiares do catálogo são testados por rank parametrizado: igualdade permite; nível seguinte nega. Clearance ausente/expirada/inactiva e classificação inactiva negam. Elevação exige checker distinto; self-elevation, payload/versão adulterados e replay negam. Bootstrap recebe apenas nível mínimo explícito.

Fonte executável: `tests/integration/authorization.test.mjs`, regressão `tests/integration/authentication.test.mjs` e `tests/auth-browser/identity.spec.mjs`. Fixtures exclusivamente TEST/CI, bases descartadas; zero mocks operacionais.

Resultado local e hashes: CHECKS.json. Resultado remoto e revisão independente: CI.md e atestação final do commit. Nenhum PASS final se CI/revisão estiver pendente.
