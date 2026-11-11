# M1C — Delegação e approval

Concessão exige grantable_set explícito, scope administrativo e ceiling limitado pela clearance actual. Ter permission não basta: expirar a delegação nega. Cross-scope e edição de role própria negam. Approvals têm actor/target/op/payload hash/policy version/validade/session maker/checker/state/idempotency; revalidação e consumo atómicos. Replay, maker perdido, expiração, payload/approver fabricado e política antiga negam.

Fonte executável: `tests/integration/authorization.test.mjs`, regressão `tests/integration/authentication.test.mjs` e `tests/auth-browser/identity.spec.mjs`. Fixtures exclusivamente TEST/CI, bases descartadas; zero mocks operacionais.

Resultado local e hashes: CHECKS.json. Resultado remoto e revisão independente: CI.md e atestação final do commit. Nenhum PASS final se CI/revisão estiver pendente.
