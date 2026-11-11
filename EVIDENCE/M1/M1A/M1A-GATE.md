# M1A — Security Architecture Gate

Este é o gate arquitectural anterior à publicação. O gate de publicação, a regressão M0 repetida e a evidência remota seguem PUBLICATION.md; referências abaixo a entrega apenas local e ausência de commit descrevem o checkpoint original.

Data: 2026-11-11. Estado: GATE_PASSED. Autoridade: master FROZEN intacto e ordem M1 com execução exclusivamente M1A. Avaliação técnica documental; não é aceitação institucional nem gate final de M1.

## Matriz de aceitação

| Critério | Decisão | Evidência |
|---|---|---|
| DoR/plano e DoD aplicável a desenho | PASS | docs/requirements/M1A-PLAN.md; sete contratos e quatro ADRs |
| Security Context Contract | APPROVED | SCC/1; ADR-007; revisão independente |
| Authentication Architecture | APPROVED | SES/1; ADR-009; boundary auth separado |
| Session Architecture | APPROVED | SES/1, ADC/1; timeout/revogação/locks/CSRF definidos |
| Authorization model | APPROVED | ADC/1; ADR-008; API/SQL e executores IAM |
| RBAC model | APPROVED | RAM/1; effective_grants sem mistura de scopes |
| ABAC model | APPROVED | RAM/1, ADC/1; predicados conjuntivos |
| RLS architecture | APPROVED | RLS/1; ADR-010; bindings privados/roles/execução restrita |
| Classification architecture | APPROVED | CLS/1; rank configurável e fail-closed |
| Compartments | APPROVED | CLS/1; ALL memberships + need-to-know |
| Segregation of Duties | APPROVED | SOD/1; conflitos temporais, maker-checker e self-protection |
| Default deny | CONFIRMED | SCC/ADC/RLS: ausência/erro/versão inválida nega |
| Revisão crítica independente | PASS | ASTRA-REVIEW.md: REQUEST_CHANGES inicial, quatro findings CLOSED após re-review, APPROVE final |
| Freeze / integridade da revisão | PASS | FREEZE-MANIFEST.json e REVIEWED-DRAFT-HASHES.json; apenas estados mudados após revisão |
| Master integrity | PASS | SHA-256 histórico idêntico em CHECKS.json |
| Preservação M0 | PASS | Git diff HEAD vazio para ficheiros controlados; CI de base três jobs success, sem novo run M1 |
| Zero mocks operacionais | PASS | check-policy: operationalFindings=0; nenhuma implementação M1 adicionada |
| Secret scan da entrega | PASS | Gitleaks v8.30.1 exit 0, GITLEAKS-SOURCE.json=[] |
| Sem M1B/C/D ou M2 funcional | PASS | CHECKS.json: adições exclusivamente documentais autorizadas; runtime/SQL/API/UI/CI intactos |
| Artefactos e rastreabilidade | PASS | Cinco relatórios M1, plano, contratos, ADRs, review, manifesto e verificações |

A revisão ASTRA aprovou os onze ficheiros exactos cujos hashes DRAFT constam da evidência. O freeze conserva a semântica, confirmado por reconstrução do draft e hash. Não há finding crítico/alto aberto na revisão arquitectural. Pendências de medição e implementação não são testes passados; constam de M1_KNOWN_ISSUES.md e M1_TEST_REPORT.md. Regras institucionais de classificação/recuperação e sign-off humano permanecem obrigatórios antes de produção.

M0 continua com a implementação/CI de base preservada segundo Git; a suite operacional não foi repetida para este diff documental. Não há execução PostgreSQL IAM, RLS SQL, login ou E2E M1 nesta fase. Não se declara M1_GATE = PASS nem PRODUCTION_READY. Entrega local na branch main, sem commit/push/workflow M1A.

## Decisão

M1A_GATE = PASS

M1B = BLOCKED_PENDING_EXPLICIT_AUTHORIZATION

M1C = BLOCKED

M1D = BLOCKED

M2 = BLOCKED

Paragem neste checkpoint. Alteração semântica aos contratos congelados exige revisão e novo gate; qualquer avanço para M1B exige nova ordem explícita.
