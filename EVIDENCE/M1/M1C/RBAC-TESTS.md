# M1C — RBAC e grants vinculados

19 testes M1C na suite authorization.test.mjs. Testes de matriz, grant sem produto cartesiano, role inactiva, grants futuros/expirados e matriz negativa por executor. permission_id, assignment_id, scope_set, location_set e validade são verificados. Catálogo M1 completo; nenhum catálogo patrimonial.

Fonte executável: `tests/integration/authorization.test.mjs`, regressão `tests/integration/authentication.test.mjs` e `tests/auth-browser/identity.spec.mjs`. Fixtures exclusivamente TEST/CI, bases descartadas; zero mocks operacionais.

Resultado local e hashes: CHECKS.json. Resultado remoto e revisão independente: CI.md e atestação final do commit. Nenhum PASS final se CI/revisão estiver pendente.
