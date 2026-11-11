# Authorization Decision Contract — ADC/1

Estado: FROZEN/APPROVED M1A. Assinatura lógica: authorize(subject, action, resource, context) → { decision: ALLOW | DENY, internal_reason, policy_version, decision_id }. A resposta pública não inclui atributos classificados nem detalhes internos. Acção/recurso desconhecido, authority indisponível, contexto inválido, atributo exigido ausente ou erro de avaliação = DENY.

ALLOW apenas se: identidade ACTIVE e sessão válida; permission exacta concedida por role activa; recurso/operation suportados pela política; scope inclui recurso; clearance suficiente; todos os compartimentos requeridos estão incluídos; strength suficiente; regras SoD e delegation satisfeitas; versões coerentes. Os predicados são conjuntivos; não há allow por role-name especial, super-admin implícito, owner do recurso ou botão visível. Autoridade de administração IAM não equivale a acesso a todos os dados classificados.

A avaliação API antecede cada operação protegida. Em listagens, valida action/context e limita consulta no servidor; RLS filtra linhas e agregações. Objectos por ID são procurados sob RLS, sem lookup global que revele a sua existência. Ausência de sessão: 401; falta de capacidade conhecida: 403; ID escondido/ausente: 404 indistinguível. Erros da autoridade/auditoria: 503, sem efeito protegido. Resultado vazio nunca significa autorização de escrita.

## Catálogo de decisões

Permission e scope/localização devem pertencer ao mesmo effective_grant (RAM/1). A união de permissions e de scopes de concessões diferentes não constitui autorização. Tempo de validade de grants, clearance, compartimentos, sessão e binding é verificado pelo relógio DB wall-clock em cada decisão/statement; não usar now() fixo no início da transacção para prolongar validade. Uma query já iniciada pode terminar dentro do statement_timeout; nenhuma garantia de cancelamento retroactivo é alegada.

AUTHN_REQUIRED, SESSION_EXPIRED, SESSION_REVOKED, USER_INACTIVE, PERMISSION_DENIED, SCOPE_DENIED, CLEARANCE_DENIED, COMPARTMENT_DENIED, STRENGTH_DENIED, SOD_DENIED, DELEGATION_DENIED, CONTEXT_MISSING, CONTEXT_TAMPERED, POLICY_UNKNOWN. São motivos internos auditáveis; mensagens ao utilizador são mínimas. request_id/correlation_id são do servidor, não alteram a decisão.

## Coerência API/DB

AUTH-001: cada permission referencia uma acção e tipo de recurso do catálogo controlado. AUTH-002: uma tabela de predicados lógica versionada define os mesmos significados na API e nos helpers RLS. Implementações futuras são testadas contra uma matriz comum; comparar ALLOW/DENY para cada caso, nunca aceitar API ALLOW + RLS permissivo por conveniência. AUTH-003: USING e WITH CHECK cobrem leitura e novo estado; uma actualização não muda scope/classificação para fugir à política.

## Revogação e concorrência

READ COMMITTED, sem cache de autorização entre pedidos. Toda transacção protegida adquire lock partilhado na linha única security_policy_state; alterações de política/IAM adquirem lock exclusivo desde o início, antes de resolver contexto, e incrementam versões. Ordem global: policy_state → subject_state (UUID ordenado quando múltiplos) → sessions (UUID ordenado). Pedidos normais usam subject SHARE e sessão UPDATE para validar/actualizar idle; alterações IAM usam policy EXCLUSIVE e subject/session UPDATE. Não promover SHARE→EXCLUSIVE a meio de um pedido; rotas de alteração escolhem o modo exclusivo antes do binding, mas este modo não confere permission.

Assim, uma revogação aguarda pedidos já autorizados sob lock; após o commit de revogação, nenhum novo binding obtém acesso. Não se promete cancelar retroactivamente uma transacção que já concluiu. Prazo de locks/transactions é limitado; timeout faz rollback/503. A baseline serializa alterações IAM para preferir coerência; medir contenção antes de optimizar por novo ADR. Desenho: ADR-008/010.

Comandos de login/falha/lockout/unlock/logout/rotate/password e bootstrap também escolhem o modo de mutação desde o início, antes de qualquer leitura autenticada sob SHARE, seguindo a mesma ordem global. Não tentar elevar o lock do subject depois de bind normal. Todas as funções privilegiadas, incluindo canais auth, respeitam este protocolo e não recebem um parâmetro de bypass. lock_timeout inicial 2s; timeout aborta a operação inteira, sem resposta parcial de sucesso.

## Auditoria e falhas

Alterações à autoridade IAM não dependem exclusivamente do authorize da API: RLS/1 proíbe DML directo pelos runtimes e exige executores DB por operação que revalidam actor derivado do binding, locks, grants, delegação, SoD e estado resultante. Usar SQL directo não transforma scope suficiente em capacidade de auto-elevação.

Mudanças de identidade/entitlement/sessão e sucesso da operação são atómicos com auditoria; falha de append obriga rollback. Negação autenticada sem mutação pode auditar e commitar a decisão; falha com rollback usa canal de auditoria separado e restrito, sem reutilizar transacção abortada. Falha de banco não permite emitir sessão ou executar operação sensível; gera evento técnico sanitizado, não se alega persistência de auditoria inexistente.

Auditoria IAM: actor/target, acção, tempo DB, origem de rede validada, device limitado, session_id, request/correlation, motivo, antes/depois sem credenciais e resultado. Append-only com owner NOLOGIN, INSERT apenas por função; sem UPDATE/DELETE/TRUNCATE pelo runtime; consulta paginada protegida por scope/classificação. Operador DB/superuser pode alterar o banco: detecção contra esse actor exige checkpoints/cópia externa institucional, sem alegar imutabilidade absoluta contra DBA.
