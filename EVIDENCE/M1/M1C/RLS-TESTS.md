# M1C — FORCE RLS e API/DB

Todos os relations IAM têm ENABLE/FORCE. Ambos runtimes são testados contra DML directo e SET ROLE. SQL e API concordam em ALLOW/DENY. Listas/count paginados sob RLS; lookup por ID sem consulta global prévia. TEST-only test_policy comprova INSERT/UPDATE WITH CHECK de novo scope/classificação/compartimentos e DELETE separado. Tabelas IAM reais são alteradas exclusivamente por executores tipados, sem DML runtime.

Fonte executável: `tests/integration/authorization.test.mjs`, regressão `tests/integration/authentication.test.mjs` e `tests/auth-browser/identity.spec.mjs`. Fixtures exclusivamente TEST/CI, bases descartadas; zero mocks operacionais.

Resultado local e hashes: CHECKS.json. Resultado remoto e revisão independente: CI.md e atestação final do commit. Nenhum PASS final se CI/revisão estiver pendente.
