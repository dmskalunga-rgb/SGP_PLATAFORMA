# IAM administration — M1D

Entrar com identidade institucional e abrir Administração de segurança no perfil. As listagens paginadas mostram somente registos autorizados; erros 401/403/404/503 representam sessão inválida, operação proibida, recurso oculto/ausente ou autoridade indisponível. Não existem dados demonstrativos operacionais.

Criação de identidade exige referência IAM_SCOPE ou IAM_GLOBAL e classificação explícitas, permission e delegação do operador. A conta nasce INACTIVE, com credential privada e sem entitlements; activar a conta, atribuir role/scope e conceder clearance/compartments segundo política antes de testar acesso. A palavra-passe inicial é transmitida apenas por HTTPS e nunca regressa nas leituras. Provisionar referências institucionais por processo controlado; esta interface não cria estrutura organizacional, scopes administrativos de delegação ou catálogo arbitrário de permissions.

Roles: criar, configurar permissions e atribuir/agendar. Alterar estado reavalia impacto, SoD, delegação, own-role e capacidade mínima. Reactivar role privilegiada já atribuída é recusado: uma atribuição privilegiada deve passar pelo pedido aprovado. A edição de permissions administrativas numa role já atribuída mantém a restrição M1C. Revogar assignment exige delegação e preserva dois operadores utilizáveis.

Clearance: encurtar pode seguir redução autorizada. Rank ou janela temporal acrescidos exigem approval exacta quando acrescentam autoridade; NULL significa sem fim. Revogação não pode eliminar a capacidade administrativa mínima. Compartimento sensível exige maker-checker. Self mutation é recusada pelo backend.

Inbox: PENDING, CONSUMED (executada), REJECTED e EXPIRED derivado do relógio. A execução chama o executor original com o payload armazenado e revalida maker/checker, sessão, target, policy, delegação, SoD, validade e consumo único. Rejeitar exige segundo operador autorizado e motivo até 500 caracteres; preserva histórico e não altera entitlement. Não incluir secrets no motivo.

Sessões mostram apenas metadata sanitizada. Revogar uma ou todas as sessões de um utilizador usa o comando de conta M1B/M1C; um pedido posterior à revogação recebe 401. O logout próprio permanece no perfil.

Auditoria: exige security.audit.read e RLS por scope/classificação/compartments. Filtros actor, target, action, result, início/fim (fim exclusivo), request_id e correlation_id são aplicados no servidor. Eventos não têm editor ou remoção. Reconstituir o percurso por actor/target, request/correlation, decision e approval. Listagens completas usam limit/offset; detalhes resumem até 25 relações por secção. M1D não inicia M2.
