# M1 — relatório de milestone

M1A FROZEN e M1B publicados, preservados. Fase actual autorizada: somente M1C — RBAC, ABAC & RLS ENFORCEMENT. DoR: docs/requirements/M1C-PLAN.md. Implementação: migration 003, AuthorizationPort/API e prova mínima no perfil. Nenhuma implementação de M1D/M2.

M1C fornece catálogo exacto, grants vinculados, scope/location, clearance/classification/compartments, FORCE RLS, comandos IAM tipados, SoD temporal/dinâmica, delegação explícita, maker-checker, auditoria e invariantes de dois operadores. A base de sessão M1B e os contratos M1A não foram reescritos.

Estado verificável por controlo: EVIDENCE/M1/M1C/CHECKS.json. Decisão final somente após CI do commit publicado e revisão ASTRA, conforme EVIDENCE/M1/M1C/CI.md. A atestação final está em refs/notes/m1c-gate após conclusão. Sem ela, candidatura pendente, nunca PASS implícito.

M1D e M2 bloqueados. M1 como um todo não está concluído; não declarar PRODUCTION_READY.

Actualização H1: ASTRA confirmou extensão temporal de clearance sem segunda aprovação no SHA M1C original. A correcção forward-only em migration 004 e testes focais passaram localmente, mas o finding permanece OPEN até nova CI e re-review. `M1C_GATE = FAIL` nesta candidatura; M1D/M2 bloqueados. Ver EVIDENCE/M1/M1C/HIGH-001-CLEARANCE-TEMPORAL.md.
