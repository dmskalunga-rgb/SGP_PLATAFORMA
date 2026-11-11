# M1C — Auditoria e atomicidade

E2Es reais reconstroem criação de role/permission/assignment/clearance/compartment, decisões permitidas/negadas e revogação. Eventos têm actor/target/action/time/result/before/after/session/request/correlation/policy/decision_id. Revogar INSERT do audit_writer causa 503 e rollback da mutação. Negação de lookup commita o audit antes do 404. Canal pós-rollback só escreve DENY, sem actor/result escolhidos pelo caller; audit nunca concede autoridade.

Fonte executável: `tests/integration/authorization.test.mjs`, regressão `tests/integration/authentication.test.mjs` e `tests/auth-browser/identity.spec.mjs`. Fixtures exclusivamente TEST/CI, bases descartadas; zero mocks operacionais.

Resultado local e hashes: CHECKS.json. Resultado remoto e revisão independente: CI.md e atestação final do commit. Nenhum PASS final se CI/revisão estiver pendente.
