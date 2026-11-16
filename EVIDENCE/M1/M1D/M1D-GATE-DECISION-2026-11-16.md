# SGP-DISPO — DECISÃO HUMANA FORMAL DO M1D_GATE

**Milestone:** M1D — IAM Administration  
**Data da decisão expressa:** 16/11/2026  
**Decisão:** **M1D_GATE = PASS — APROVAÇÃO HUMANA CONDICIONADA**  
**Decisor:** Kalunga Soares  
**Qualidade declarada:** Proprietário do Sistema  
**SHA avaliado e expressamente aprovado:** `fd993a4e08d994d357b471f4c56674b0cf979a5f`  
**Branch:** `codex/m1d-iam-administration`  
**PR:** https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/pull/1

## 1. Declaração de decisão

Em 16/11/2026, Kalunga Soares declarou expressamente:

> "Na qualidade de Proprietário do Sistema, APROVO expressamente M1D_GATE = PASS para o SHA fd993a4e08d994d357b471f4c56674b0cf979a5f, condicionado às obrigações do risco M1D-RISK-503-001. Solicito o registo formal da decisão. Não autorizo merge, produção ou início de M2."

O presente ficheiro regista essa **decisão humana**, não uma aprovação autónoma do agente ou da CI. A capacidade formal declarada pelo decisor é Proprietário do Sistema; este registo não comprova autonomamente poderes legais/delegações adicionais se requeridos pela governação institucional.

## 2. Fundamento da aprovação

- **CI directa no candidato documental aprovado:** https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43845885822 — todos os jobs PASS.
- **CI do PR no candidato documental aprovado:** https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43845886517 — todos os jobs PASS.
- **Regressão reportada:** 56 testes normais PASS por execução (4 unitários, 45 integração PostgreSQL, 2 baseline browser, 5 TLS/IAM), zero falhas/skips/flaky.
- **Controlo de segurança:** SAST, secret scan, npm audit, SCA, contentores e SBOM PASS nos âmbitos declarados.
- **Rastreabilidade:** `EVIDENCE/M1/M1D/FINAL-EVIDENCE-MANIFEST.json`; 102 hashes versionados e cinco provas externas verificados no relatório de consolidação.
- **Atestação independente:** `EVIDENCE/M1/M1D/DOCUMENTARY-INDEPENDENT-ATTESTATION.md`; recomendação READY_FOR_GATE_REVIEW sem finding documental bloqueante no âmbito revisto.
- **Histórico das correcções:** auditoria de negações, role-status, inicialização CSRF/maker-checker, lifecycle TEST e migration006. As migrations001–005, Masters e contratos FROZEN permaneceram inalterados.

Os documentos anteriores que declaram `PENDING EXPLICIT HUMAN GATE DECISION` reflectem o estado histórico **antes** desta manifestação expressa; não são reescritos nem apagados por esta acta.

## 3. Aceitação condicionada do risco M1D-RISK-503-001

A aprovação é condicionada às obrigações já aceites e documentadas em `EVIDENCE/M1/M1D/M1D-RISK-503-001-ACCEPTANCE.md`.

- **Responsável técnico da investigação:** Kalunga Soares.
- **Autoridade que manifestou a aceitação:** Kalunga Soares, Proprietário do Sistema (qualidade declarada).
- **Causa-raiz do HTTP 503 histórico:** ainda **desconhecida**; a investigação permanece **ABERTA**.
- **Prazo:** 15 dias corridos a partir da formalização válida; **01/12/2026** é a data-limite proposta, sujeita à regra de validade e contagem aplicável.
- **Controlo:** monitorizar recorrências HTTP 503, latência, timeouts, SQLSTATE, locks e utilização/encerramento de pools; preservar evidências sanitizadas e reabrir o risco perante recorrência, indisponibilidade relevante, inconsistência ou indícios de perda de auditoria, bypass ou falha de integridade.
- Esta aceitação não equivale a correção da causa-raiz nem autoriza dispensar os controlos de segurança.

## 4. Limites expressos da decisão

A declaração **M1D_GATE = PASS** encerra a avaliação do milestone M1D **no SHA expressamente aprovado**, com o risco residual condicionado. **NÃO** autoriza:

1. Merge do PR #1 nem alteração de `main`.
2. Deployment ou utilização em produção.
3. Início de M2.
4. Declaração automática de `M1_FINAL_GATE = PASS`.
5. Execução ou aprovação automática do CR-SGP-002.
6. Alteração dos Masters FROZEN, dos contratos FROZEN ou das migrations publicadas.

O passo seguinte exige autorização separada conforme a cadeia de governação; **M2 permanece BLOCKED**.

## 5. Vinculação da acta ao repositório

Esta acta é um **commit documental posterior** ao SHA aprovado. A publicação cria inevitavelmente outro SHA na branch do PR. O SHA da decisão e as CIs anteriores **não devem ser confundidos**: as CIs indicadas avaliam o SHA `fd993a4e08d994d357b471f4c56674b0cf979a5f`. Qualquer CI disparada pelo presente commit documental deve ser verificada e registada separadamente antes de eventual promoção.

A presente acta é um registo da manifestação expressa do decisor na conversação de governação, não uma assinatura criptográfica nem uma validação independente de poderes.

**Situação após esta decisão:** `M1D_GATE = PASS (HUMAN APPROVED, RISK-CONDITIONED)`; `PR #1 = DRAFT / NO MERGE`; `M1_FINAL_GATE = PENDING`; `M2 = BLOCKED`; `PRODUCTION = NOT AUTHORIZED`.
