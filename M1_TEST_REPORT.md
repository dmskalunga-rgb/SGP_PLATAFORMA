# M1 — testes e evidências no checkpoint M1A

Actualização de publicação: a regressão operacional M0 exigida pela ordem de publicação é registada separadamente em [PUBLICATION](EVIDENCE/M1/M1A/PUBLICATION.md) e PUBLICATION-REGRESSION.json. As afirmações abaixo sobre testes não repetidos pertencem ao checkpoint arquitectural anterior; continuam sem existir testes operacionais IAM M1 nesta entrega.

Actualização de publicação: a regressão operacional M0 exigida pela ordem de publicação é registada separadamente em [PUBLICATION](EVIDENCE/M1/M1A/PUBLICATION.md) e PUBLICATION-REGRESSION.json. As afirmações abaixo sobre testes não repetidos pertencem ao checkpoint arquitectural anterior; continuam sem existir testes operacionais IAM M1 nesta entrega.

Esta subfase é documental. Os resultados efectivamente executados são os de [CHECKS](EVIDENCE/M1/M1A/CHECKS.json) e da revisão independente [ASTRA](EVIDENCE/M1/M1A/ASTRA-REVIEW.md). Não foram executados testes de autenticação, autorização, RLS ou E2E IAM: não há implementação M1 autorizada. Nenhum teste planeado abaixo equivale a PASS operacional.

## Verificação desta entrega

Integridade SHA-256 do master; existência dos sete contratos e quatro ADRs; diff exclusivamente documental; nenhuma alteração ao conteúdo controlado da implementação/CI M0 (normalização Git de fins de linha); freeze por SHA-256; política zero mocks; secret scan dos ficheiros da entrega. Comandos, códigos de saída e limitações: EVIDENCE/M1/M1A/COMMANDS.md e CHECKS.json. CI de base M0 com PostgreSQL real e três jobs success é evidência herdada do commit base, não execução M1 nova.

## Obrigações ainda NÃO EXECUTADAS

| Subfase futura | Casos mínimos / critérios |
|---|---|
| M1B | Login válido/inválido, inexistente, DISABLED, LOCKED; Argon2/calibração e limites; nonce/login CSRF/Origin; cookie/TLS; expiry idle/absolute; logout, revogação, rotação/replay, credential-version; falhas de banco/audit; eventos de autenticação; browser real |
| M1C | AUTH-001–003, CTX-001–005, RLS-001–012, CLS-001–003: grants sem mistura de scope, allow/deny por dimensão, SQL directo e API, USING/WITH CHECK, FORCE RLS, views/definer/role privileges, GUC tampering e pool max=1 após commit/rollback/timeout/cancel, concorrência/revogação, DML IAM directo negado, CLOSED/savepoints/deadline |
| M1D | SOD-001–006; CRUD IAM real, scope/delegação/ceilings, último admin, maker-checker/replay, conflitos temporais, audit query e reconstrução; E2E positivo e negativo completos com PostgreSQL e frontend reais |
| M1-GATE futuro | Regressão M0 completa; lint/type/build, unit/integration/API/DB/browser; SAST/SCA/secret/image scans/SBOM; zero vulnerabilidade crítica/alta aberta; gates anteriores e evidências |

Casos negativos retiram cada requisito isoladamente de um caso permitido. Resultados API e SQL devem ser comparados, inclusive grants de mesma permission em scopes distintos e scope sem permission correspondente. Fixtures são efémeras em TEST, identificáveis, sem entidades patrimoniais antecipadas e sem rota TEST em produção. A suite M0 permanece obrigatória; o diff documental actual não substitui os testes executáveis futuros.
