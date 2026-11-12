# M1 — relatório de milestone

M1A FROZEN e M1B publicados, preservados. Fase actual autorizada: somente M1C — RBAC, ABAC & RLS ENFORCEMENT. DoR: docs/requirements/M1C-PLAN.md. Implementação: migration 003, AuthorizationPort/API e prova mínima no perfil. Nenhuma implementação de M1D/M2.

M1C fornece catálogo exacto, grants vinculados, scope/location, clearance/classification/compartments, FORCE RLS, comandos IAM tipados, SoD temporal/dinâmica, delegação explícita, maker-checker, auditoria e invariantes de dois operadores. A base de sessão M1B e os contratos M1A não foram reescritos.

Estado verificável por controlo: EVIDENCE/M1/M1C/CHECKS.json. Decisão final somente após CI do commit publicado e revisão ASTRA, conforme EVIDENCE/M1/M1C/CI.md. A atestação final está em refs/notes/m1c-gate após conclusão. Sem ela, candidatura pendente, nunca PASS implícito.

M1D e M2 bloqueados. M1 como um todo não está concluído; não declarar PRODUCTION_READY.

Actualização H1: ASTRA confirmou extensão temporal de clearance sem segunda aprovação no SHA M1C original. A correcção forward-only em migration 004 e testes focais passaram localmente, mas o finding permanece OPEN até nova CI e re-review. `M1C_GATE = FAIL` nesta candidatura; M1D/M2 bloqueados. Ver EVIDENCE/M1/M1C/HIGH-001-CLEARANCE-TEMPORAL.md.

Fecho H1: commit técnico [161e246](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/161e246614fb3da8cc3c950f9ed5cf0c42cc301e) publicado; CI [43167843976](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43167843976) PASS. A re-review ASTRA foi recusada automaticamente por possível risco de cibersegurança, sem parecer. HIGH-001 segue OPEN; M1C_GATE = FAIL; M1D/M2 BLOCKED.

Após `CR-M1C-REVIEW-001`, revisor substituto independente SOL + Alto confirmou HIGH-001 tecnicamente corrigido. A revisão completa dos 40 pontos descobriu `M1C-SUB-MEDIUM-001`: o pipeline CI pode mascarar falha de teste de integração. O parecer final é FAIL; HIGH-001 permanece OPEN para governação, M1C_GATE FAIL e M1D/M2 BLOCKED. Ver `EVIDENCE/M1/M1C/INDEPENDENT-REVIEW-H1.md`.


## Fecho MEDIUM-001 — 2026-11-12

Correcção focal publicada em [0643595](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/0643595faa20422643aa712c104d302f2f743ba1). [CI 43205905235](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43205905235): três jobs PASS, 48/48 testes normais, zero falhas/skips, scanners PASS e quatro SBOM. Provas remotas: producer23/pipeline23, sucesso0, teste Node temporário falhado/pipeline1. Ambos os pipelines críticos usam Bash/pipefail e conservam logs. Business code e migrations intactos.

Re-review independente read-only `/root/medium_final_review`, dispatch GPT-6.1 SOL + Alto, fork sem contexto: oito critérios §14 PASS, sem novos findings CRITICAL/HIGH/MEDIUM/LOW. Provas e limites em MEDIUM-001-CI-FAIL-CLOSED.md. O teste falhado controlado usa node:test temporário, não PostgreSQL; regressão PostgreSQL normal passou. O checker protege o formato actual dos dois steps e não é parser geral YAML/Shell.

Esta decisão substitui os estados FAIL anteriores preservados neste histórico: **M1C-ASTRA-HIGH-001 = CLOSED; M1C-SUB-MEDIUM-001 = CLOSED; INDEPENDENT_REVIEW = PASS; M1C_GATE = PASS; M1D = BLOCKED_PENDING_EXPLICIT_AUTHORIZATION; M2 = BLOCKED.** A atestação exacta com SHA documental/CI encontra-se em refs/notes/m1c-gate. STOP antes de M1D/M2.
