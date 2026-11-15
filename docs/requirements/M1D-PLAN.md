# M1D — DoR e DoD

Autoridade: Master FROZEN, contratos M1A e autorização canónica M1D recebida em 2026-11-12. Base publicada: 7ee4db8. M1C PASS comprovado por CI e revisão independente; CHECKS sincronizado antes de alterar funcionalidade. M2 e domínios posteriores bloqueados.

DoR: operadores autenticados e segundo operador distinto; PostgreSQL real; catálogo M1C; scopes técnicos opacos; metadados institucionais explícitos; zero seeds operacionais fictícios. Migrations 001–004 e contratos FROZEN imutáveis. Novas operações usam migration forward-only, executores tipados, locks policy/subject/session, delegação e SoD, self-protection, dois operadores, audit atómico e invalidação de versões. Expansão de clearance preserva integralmente HIGH-001. Nenhum DML IAM directo para runtimes.

Entrega: utilizadores/roles/assignments/clearances/compartments, inbox approve/reject, sessões sanitizadas, audit com filtros/paginação servidor; detalhe de utilizador e role; UI real com estados loading/empty/error/success e formulários validados. API mantém 401/403/404/503 e não confia em claims do browser. Catálogo de permissions só leitura.

DoD: testes PostgreSQL/API e browser E2E para criação→acesso, entitlement/session revocation, maker-checker/replay, reconstrução de audit, negativos por API e SQL, self-escalation e capacidade mínima. Regressões M0/M1B/M1C, HIGH-001, policy MEDIUM-001; OpenAPI e documentação; evidência M1D por controlo; scanners/SBOM e CI do SHA publicado; reviewer independente diferente do implementador. PASS apenas com todos os gates satisfeitos; caso contrário FAIL e M1 bloqueado. STOP antes de M2 mesmo após PASS.

## Inventário antes da migration 005

| Operação | Estado | Implementação existente / extensão necessária |
|---|---|---|
| users list/get | EXISTS_AND_REUSABLE | API security/users sob RLS; falta UI |
| users activate/deactivate/lock/unlock | EXISTS_AND_REUSABLE | account_command e API auth/admin; falta UI |
| create identity | MISSING_TYPED_EXECUTOR | criar com metadata explícita, credential hash privado e audit |
| roles list/get/create | EXISTS_AND_REUSABLE | security/roles, create_role; falta UI |
| role permissions add/remove | EXISTS_AND_REUSABLE | set_role_permission; falta leitura de detalhe/UI |
| role activate/inactivate | MISSING_TYPED_EXECUTOR | impacto em assignments, own-role, SoD e capacidade |
| permissions list/read | EXISTS_AND_REUSABLE | catálogo fechado, sem editor |
| user_roles assign/schedule/revoke | EXISTS_AND_REUSABLE | assign_role/revoke_assignment; falta leitura e UI |
| security_clearances grant/reduce/extend | EXISTS_AND_REUSABLE | grant_clearance migration004; falta UI/leitura |
| clearance revoke | MISSING_TYPED_EXECUTOR | redução explícita com self/delegation/capacidade/audit |
| security_compartments/user_compartments | EXISTS_BUT_NEEDS_M1D_API | grant_compartment existente; leitura/UI e revoke ausentes |
| sessions list/revoke one/all | EXISTS_AND_REUSABLE | security/sessions + account_command; falta UI |
| approvals inbox | MISSING_READ_QUERY | leitura paginada/RLS sanitizada; estados derivados de validade |
| approval execute/reject | MISSING_TYPED_EXECUTOR | dispatch tipado aos executores existentes; rejeição auditada sem entitlement |
| authentication_events/authorization_events | MISSING_READ_QUERY | audit IAM existe; faltam filtros servidor e UI |

Todas as operações administrativas carecem de MISSING_UI. Scopes são referências IAM_SCOPE; concessão de scope acompanha assignment existente, sem editar delegation_authority pelo browser. A leitura de dados de segurança mantém permissions próprias e RLS, sem unir tabelas privilegiadas fora desse boundary. API nova não duplica os executores correctos M1C.
