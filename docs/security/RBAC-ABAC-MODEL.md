# RBAC + ABAC — RAM/1

Estado: FROZEN/APPROVED M1A. Modelo lógico apenas, sem SQL, seed operacional ou administração implementados.

## Entidades

users; roles(id, code, status, version); permissions(id, code, action, resource_type, status); user_roles(user_id, role_id, scope_id, valid_from/to); role_permissions(role_id, permission_id). Constraints planeadas: PK/FK/UNIQUE, validade temporal e estados controlados; não guardar lista de roles no browser como fonte de verdade. Não há herança recursiva entre roles no M1: permissions são herdadas da associação role-permission. Remover/inactivar role ou vínculo invalida o subject/version da autoridade.

ABAC: user_security_attributes, user_scope_bindings, user_location_bindings, security_clearances e user_compartments. Atributos: employment_status, org_unit/scope, location, clearance, compartments, authentication_strength; department/section/asset_category/mission são dimensões futuras declaradas, não valores ou módulos implementados. Dimensão desconhecida exigida por política nega; dimensão explicitamente não aplicável ao tipo do recurso não é uma autorização universal.

## Organização mínima sem M2

Autoridade efectiva é um conjunto de grants (permission_id, assignment_id, scope_set, location_set, valid_from/to), preservando o vínculo user_roles que concedeu cada permission. Autorizar requer pelo menos um grant da permission exacta cujo scope E localização cubram o recurso. Nunca calcular permissions × união de scopes/localizações de outras roles: isso ampliaria privilégios. org_scope e permissions no envelope são resumos para apresentação; os grants vinculados são obrigatórios para decisões API e SQL. user_scope_bindings/user_location_bindings limitam o grant por intersecção, nunca o ampliam. Um grant global IAM é tipado explicitamente e não se mistura com grants scoped.

M1 usa security_scope_refs com UUID opaco, status e tipo IAM_SCOPE; não define departamentos, secções, nomes hierárquicos, árvores ou CRUD organizacional. Vínculos reais são fornecidos por operador autorizado; TEST usa UUIDs efémeros identificados como fixtures. M2 poderá ligar referências a unidades institucionais através de migration/ADR preservando IDs e sem converter um scope vazio em wildcard.

org_unit_id primário null não concede acesso; org_scope vazio nega recursos scoped. Recursos sem scope só existem quando o tipo/política explicitamente os marca como IAM global, com permission global própria. Não existe '*' genérico nem um scope global que elimine clearance/compartimentos. Um administrador IAM global gere metadados de segurança conforme delegação e SoD, sem obter acesso automático a conteúdo classificado.

## Permissões M1 planeadas

security.users.read/create/update/disable/lock/unlock; security.roles.read/manage; security.permissions.read; security.assignments.manage; security.clearances.read/manage; security.compartments.read/manage; security.sessions.read/revoke; security.audit.read. Acções self profile/session são separadas das administrativas. Catálogo exacto e contratos OpenAPI serão implementados nas subfases autorizadas; não criar catálogo patrimonial.

## Regras de delegação

Possuir roles.manage não permite auto-atribuição ou conceder qualquer poder. Toda concessão exige alvo diferente do actor, scope dentro do administrative_scope, nível não superior ao ceiling do actor e entitlement incluído num conjunto grantable explícito. Possuir uma permission não a torna automaticamente delegável. Editar o conteúdo de role verifica todos os membros afectados, conflicts SoD e restrições de delegação; rejeita transacção inteira se resultar elevação proibida. Role inactiva não confere capacidade e só pode activar após a mesma validação.

## Matriz mínima de conformidade

Escritas em entidades IAM apenas por executores DB do RLS/1, sem DML directo runtime. Delegação e SoD são verificadas nesses executores, além da API; intervalos agendados também seguem SOD/1.

Caso base com permission+scope+clearance+compartimento → ALLOW. Retirar cada dimensão isoladamente → DENY. Role inactiva, utilizador revogado, session expirada, permission desconhecida, body com claims falsos → DENY. Listagens/contagens não expõem recursos fora do scope. Modificar scope/clearance/compartimentos próprios ou conceder role não delegável → DENY, mesmo por API directa. Aplicação e SQL devem produzir os mesmos resultados.
