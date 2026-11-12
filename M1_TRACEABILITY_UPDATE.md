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
