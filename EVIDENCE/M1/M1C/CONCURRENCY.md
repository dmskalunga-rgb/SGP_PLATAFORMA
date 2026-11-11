# M1C — Concorrência, pool e savepoints

Policy SHARE/EXCLUSIVE desde início, sujeitos/sessões em UUID order; mutações serializadas conservadoramente. Revogação espera um request autorizado, só depois commita e o novo request nega. Pool max=1 com COMMIT/ROLLBACK/timeout não conserva contexto. Rollback anterior ao bind desfaz o audit daquele actor; savepoint posterior/finish/rebind não muda identidade sobrevivente. Regressão M1B testa transaction_timeout real de 15s com statements curtos.

Fonte executável: `tests/integration/authorization.test.mjs`, regressão `tests/integration/authentication.test.mjs` e `tests/auth-browser/identity.spec.mjs`. Fixtures exclusivamente TEST/CI, bases descartadas; zero mocks operacionais.

Resultado local e hashes: CHECKS.json. Resultado remoto e revisão independente: CI.md e atestação final do commit. Nenhum PASS final se CI/revisão estiver pendente.
