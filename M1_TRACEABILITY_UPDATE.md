# M1C — rastreabilidade

| Ordem canónica | Implementação / prova |
|---|---|
| §§1–4, 14–16 | DoR M1C-PLAN; AuthorizationPort PostgreSQL, default deny e HTTP 401/403/404/503 |
| §§5–8 | Catálogo exacto, effective_grants vinculados e scopes IAM_SCOPE; testes RBAC |
| §§9–13 | user_security_attributes, scope/location, classifications/clearances e compartments; matriz API/SQL e limiares |
| §§17–25 | FORCE RLS, binding privado (pid,xid8), GUCs derivados, ACL sem DML, executores tipados/search_path |
| §§26–30 | policy locks, subject_version, UUID order, revogação linearizada e timeouts M1B |
| §§31–38 | SoD estática/temporal/dinâmica, grantable_set/ceiling, approvals/hash/session/version/idempotency e capacidade de dois operadores |
| §§39–54 | Matriz comum, USING/WITH CHECK/DELETE, paginação/count/ID protegido, audit atomicity, SQL bypass, pool/savepoints |
| §§55–56 | Perfil com consulta mínima autorizada; browser/API prova UX; fixtures apenas TEST |
| §§57–62 | CI integra regressões, 19 testes M1C, negativos por executor e três E2Es PostgreSQL reais |
| §§63–67 | Evidências M1C, CI por SHA, Git note final e revisão independente ASTRA |
| §§68–72 | Escopo M1C; ASTRA só revisão; STOP antes de M1D/M2 |

Evidências por controlo: EVIDENCE/M1/M1C/. Contratos FROZEN e master não modificados. M1B continua em migration 002, sem drift de checksum; migration 003 é incremental.

| Ordem H1 | Prova |
|---|---|
| §§2–7, 14–18 | migration 004, comparador multirange e testes de extensão/redução/rank |
| §§8–13, 19–24 | payload ligado ao estado antigo/proposto, maker/checker, expiração, policy version e replay |
| §§25–28 | DML directo negado, API directa negada, auditoria de sucesso/negação; testes H1 PostgreSQL reais |
| §§29–34 | regressão local 48/48; CI e re-review do novo SHA pendentes antes de closure |

Migrações 001–003 e contratos FROZEN permanecem inalterados.

Fecho H1: CI do commit técnico corrigido no [run 43167843976](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43167843976) PASS. A etapa independente ASTRA foi recusada automaticamente antes da execução; §32–34 da ordem H1 continuam insatisfeitos. HIGH-001 OPEN, M1C_GATE FAIL, M1D/M2 BLOCKED.

`CR-M1C-REVIEW-001` substituiu apenas a identidade do reviewer. Parecer independente em `EVIDENCE/M1/M1C/INDEPENDENT-REVIEW-H1.md`: H1-01–17 PASS; matriz original 39 PASS, ponto 37 FAIL devido a `M1C-SUB-MEDIUM-001` na CI. Parecer final FAIL; nenhuma alteração técnica implementada nesta revisão. HIGH-001 OPEN para governação, M1C_GATE FAIL.


## Fecho MEDIUM-001 — 2026-11-12

Correcção focal publicada em [0643595](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/0643595faa20422643aa712c104d302f2f743ba1). [CI 43205905235](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43205905235): três jobs PASS, 48/48 testes normais, zero falhas/skips, scanners PASS e quatro SBOM. Provas remotas: producer23/pipeline23, sucesso0, teste Node temporário falhado/pipeline1. Ambos os pipelines críticos usam Bash/pipefail e conservam logs. Business code e migrations intactos.

Re-review independente read-only `/root/medium_final_review`, dispatch GPT-6.1 SOL + Alto, fork sem contexto: oito critérios §14 PASS, sem novos findings CRITICAL/HIGH/MEDIUM/LOW. Provas e limites em MEDIUM-001-CI-FAIL-CLOSED.md. O teste falhado controlado usa node:test temporário, não PostgreSQL; regressão PostgreSQL normal passou. O checker protege o formato actual dos dois steps e não é parser geral YAML/Shell.

Esta decisão substitui os estados FAIL anteriores preservados neste histórico: **M1C-ASTRA-HIGH-001 = CLOSED; M1C-SUB-MEDIUM-001 = CLOSED; INDEPENDENT_REVIEW = PASS; M1C_GATE = PASS; M1D = BLOCKED_PENDING_EXPLICIT_AUTHORIZATION; M2 = BLOCKED.** A atestação exacta com SHA documental/CI encontra-se em refs/notes/m1c-gate. STOP antes de M1D/M2.
