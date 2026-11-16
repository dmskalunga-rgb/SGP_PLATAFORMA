# SGP-DISPO — Registo de aceitação condicionada do risco residual M1D-RISK-503-001

**Projecto:** SGP-DISPO — Sistema de Gestão do Património
**Milestone:** M1D — IAM Administration
**Identificador:** M1D-RISK-503-001
**Data da decisão expressa:** 2026-11-16
**SHA técnico submetido à decisão:** `9e1fe6bd3f8219a1b267eadb8e80458f221b699e`
**PR:** #1 — `codex/m1d-iam-administration` (Draft; não autorizado merge)
**Tipo:** Aceitação humana expressa, condicionada e limitada ao encerramento M1D
**Estado de governação:** RISCO RESIDUAL ACEITE CONDICIONALMENTE; `M1D_GATE` NÃO APROVADO

## 1. Risco e avaliação

Ocorrência histórica e intermitente de HTTP 503 na consulta ampla de auditoria. A causa-raiz permanece por identificar. As execuções finais de CI do candidato técnico passaram sem recorrência observada, mas isso não comprova eliminação definitiva da causa.

**Impacto potencial:** indisponibilidade temporária da consulta de auditoria, com atraso na investigação e recuperação da informação. Não foi apresentada evidência de perda de eventos, bypass de autorização ou mutações indevidas relacionadas com esta ocorrência.

**Probabilidade:** não quantificável com as evidências actuais.

## 2. Decisão humana e identificação dos responsáveis

O declarante manifestou expressamente: **"CONFIRMO, ACEITO E APROVO A DECISÃO"**, e subsequentemente confirmou as designações abaixo, por duas vezes, em 2026-11-16.

- **Decisão:** APROVAR a aceitação condicionada do risco `M1D-RISK-503-001`, exclusivamente para efeitos de encerramento do milestone M1D.
- **Responsável técnico pela investigação:** Kalunga Soares.
- **Autoridade de aceitação:** Kalunga Soares, na qualidade declarada de **Proprietário do Sistema**.
- **Origem da declaração:** confirmação expressa do responsável na conversação de governação, em 2026-11-16.
- **Limite de atestação:** as identidades e a qualidade acima são designações expressamente declaradas pelo decisor; este registo não constitui prova independente de poderes legais ou de delegação de competência, caso esses sejam exigidos por norma aplicável.

## 3. Condições vinculadas à aceitação

O responsável técnico deverá:

1. Investigar, identificar quando possível e documentar a causa-raiz do HTTP 503.
2. Monitorizar, com dados sanitizados, frequência das respostas 503, latência da consulta, SQLSTATE, timeouts, locks, correlação de pedidos e saturação/encerramento dos pools PostgreSQL.
3. Preservar logs e evidências sem expor parâmetros sensíveis, dados classificados, credenciais ou segredos.
4. Comunicar imediatamente qualquer recorrência relevante ou agravamento e submeter o risco a nova avaliação.
5. Elaborar relatório verificável de investigação e medidas correctivas.
6. Não usar esta aceitação para desactivar auditoria, autorização, RLS, testes de segurança ou controlos de produção.

**Prazo de investigação:** 15 dias corridos a contar da formalização válida. A manifestação e identificação dos responsáveis foram concluídas em 2026-11-16; **data-limite proposta: 2026-12-01**, sujeita à confirmação de validade formal e da regra de contagem pela autoridade de governação.

**Reabertura obrigatória:** qualquer recorrência inesperada em regressão obrigatória, recorrência em uso autorizado, inconsistência/indisponibilidade relevante de auditoria, indício de perda de eventos, bypass de autorização ou falha de integridade.

## 4. Separação entre aceitação de risco e aprovação de milestone

Esta aprovação **não** concede `M1D_GATE = PASS`, não aprova a revisão final do gate, não autoriza merge do PR #1, não autoriza deployment em produção e não autoriza iniciar M2 ou o CR-SGP-002.

O `M1D_GATE` permanece **BLOCKED/PENDING HUMAN GATE DECISION**, dependendo da verificação final dos restantes critérios, evidências e competências de aprovação. O `M2` permanece **BLOCKED**.

Este ficheiro é uma evidência documental autónoma e não altera o Master v1.1 FROZEN, contratos FROZEN, migrations 001–006 nem decisões de milestones anteriores.

## 5. Rastreabilidade e integridade

- Candidato técnico de referência: `9e1fe6bd3f8219a1b267eadb8e80458f221b699e`.
- CI directa: https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43805975302
- CI do PR: https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43805979032
- PR: https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/pull/1
- Esta evidência foi acrescentada após o SHA técnico referido. A nova revisão documental do PR requer verificar a CI associada ao novo SHA; os resultados técnicos anteriores não são retroactivamente atribuídos ao novo SHA.

**Declaração de aprovação:** Kalunga Soares — Proprietário do Sistema (qualidade declarada).

**Data:** 16/11/2026.

**Estado final desta acta:** decisão de aceitação condicionada formalmente registada; decisão do M1D_GATE permanece independente e pendente.
