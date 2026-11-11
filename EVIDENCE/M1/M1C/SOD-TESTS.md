# M1C — SoD estática, temporal e dinâmica

Pares incompatíveis de role e permission; conflito indirecto ao editar role; intervalos futuros sobrepostos rejeitados e adjacentes aceites. Actor=target, maker=checker e self role/clearance/compartment negados. Duas remoções concorrentes de operadores negadas. Agendamento que elimina a capacidade permanente do segundo operador rejeitado.

Fonte executável: `tests/integration/authorization.test.mjs`, regressão `tests/integration/authentication.test.mjs` e `tests/auth-browser/identity.spec.mjs`. Fixtures exclusivamente TEST/CI, bases descartadas; zero mocks operacionais.

Resultado local e hashes: CHECKS.json. Resultado remoto e revisão independente: CI.md e atestação final do commit. Nenhum PASS final se CI/revisão estiver pendente.
