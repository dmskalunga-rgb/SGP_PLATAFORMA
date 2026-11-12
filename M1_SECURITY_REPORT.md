# M1 — segurança M1C

Master e onze contratos M1A permanecem sujeitos ao guard SHA-256 exacto. Default deny: session/binding privado, versions, permission e scope/location do mesmo effective_grant, clearance, todos os compartimentos, strength e SoD. GUCs apenas propagam atributos derivados; não são credenciais.

Runtimes sem superuser/BYPASSRLS/CREATEDB/CREATEROLE/membership/ownership. Sem INSERT/UPDATE/DELETE/TRUNCATE IAM directo. Funções tipadas têm owners NOLOGIN, search_path fixo, tabelas qualificadas e EXECUTE específico sem PUBLIC/LEAKPROOF. Mutação escolhe lock policy EXCLUSIVE antes dos subjects/sessions ordenados; leituras SHARE, sem upgrade. Audit e mudança são atómicos.

Delegação é configuração explícita, não inferida de permissions. Nenhum self grant ou edição de role própria; role administrativa atribuída não recebe mudança indirecta de permissions. Aprovação revalida maker, sessão original, atributos actuais, policy, payload e checker distinto; consumo único. Dois operadores utilizáveis e permanentes são protegidos contra remoções/agendamentos administrativos previsíveis. Lockout/expiração reais continuam fail-closed.

SAST/SCA/secrets/container/SBOM: resultados medidos em EVIDENCE/M1/M1C/CHECKS.json e CI.md. Nenhum scan pendente significa PASS; nenhum HIGH/CRITICAL não resolvido pode ser aceite pelo gate. Revisão ASTRA independente posterior à CI é obrigatória.

Limites: auth process e migration/DBA são boundaries privilegiados; TLS/CA/provisionamento institucional, configuração de classificação/delegação, capacidade de hardware, recuperação, retenção e cópia externa de audit continuam responsabilidades de deployment. M1D/M2 não iniciados.

Actualização H1: o comparador temporal na migration 004 considera `valid_to=NULL` ilimitado e exige aprovação distinta para qualquer expansão de autoridade não coberta. O payload guarda estado anterior, proposta e versão; execução relê o PostgreSQL sob lock e consumo único. O finding HIGH-001 segue OPEN até scans, CI e re-review ASTRA do novo SHA; nenhum resultado antigo fecha essa condição.

Scans remotos do [run 43167843976](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43167843976) passaram com zero findings SAST/secrets/npm audit e zero vulnerabilidades Trivy HIGH/CRITICAL, quatro SBOM. A revisão automática recusou a tarefa ASTRA por possível risco de cibersegurança; a correcção não recebeu parecer independente. HIGH-001 OPEN para governação; M1C_GATE FAIL.

O revisor substituto independente autorizado por `CR-M1C-REVIEW-001` confirmou o conserto técnico do HIGH-001. A adenda dos 40 pontos encontrou `M1C-SUB-MEDIUM-001`, MEDIUM bloqueante na CI: `npm run test:integration | tee` sem `pipefail`. Uma regressão de segurança pode deixar de reprovar automaticamente o workflow. Parecer independente final FAIL, M1C_GATE FAIL; M1D/M2 BLOCKED.


## Fecho MEDIUM-001 — 2026-11-12

Correcção focal publicada em [0643595](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/0643595faa20422643aa712c104d302f2f743ba1). [CI 43205905235](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43205905235): três jobs PASS, 48/48 testes normais, zero falhas/skips, scanners PASS e quatro SBOM. Provas remotas: producer23/pipeline23, sucesso0, teste Node temporário falhado/pipeline1. Ambos os pipelines críticos usam Bash/pipefail e conservam logs. Business code e migrations intactos.

Re-review independente read-only `/root/medium_final_review`, dispatch GPT-6.1 SOL + Alto, fork sem contexto: oito critérios §14 PASS, sem novos findings CRITICAL/HIGH/MEDIUM/LOW. Provas e limites em MEDIUM-001-CI-FAIL-CLOSED.md. O teste falhado controlado usa node:test temporário, não PostgreSQL; regressão PostgreSQL normal passou. O checker protege o formato actual dos dois steps e não é parser geral YAML/Shell.

Esta decisão substitui os estados FAIL anteriores preservados neste histórico: **M1C-ASTRA-HIGH-001 = CLOSED; M1C-SUB-MEDIUM-001 = CLOSED; INDEPENDENT_REVIEW = PASS; M1C_GATE = PASS; M1D = BLOCKED_PENDING_EXPLICIT_AUTHORIZATION; M2 = BLOCKED.** A atestação exacta com SHA documental/CI encontra-se em refs/notes/m1c-gate. STOP antes de M1D/M2.
