# PostgreSQL RLS — RLS/1

Estado: FROZEN/APPROVED M1A. Desenho, não policies/migrations implementadas. PostgreSQL 17 real; usar ENABLE ROW LEVEL SECURITY e FORCE ROW LEVEL SECURITY nas tabelas sensíveis, USING e WITH CHECK por comando. Runtime não é owner, superuser ou BYPASSRLS; sem DDL, TRUNCATE, CREATE schema/function, SET ROLE privilegiado ou membership nos owners. Views não contornam políticas; preferir security_invoker e testar a identidade efectiva.

## Limite de confiança dos GUCs

SET LOCAL app.user_id/session_id/org_unit_id/clearance/compartments serve propagação, não autenticação: o runtime pode alterar custom settings. Não aceitar um user_id ou clearance arbitrário como prova de identidade. A função bind_request recebe prova opaca de sessão, calcula o hash no banco, valida sessão/identidade/versões/expiração e deriva os atributos de tabelas autoritativas, sob os locks do ADC/1. Nenhum payload fornecido pelo cliente define os atributos efectivos.

O binding insere um registo verificado privado com chave (pg_backend_pid(), pg_current_xact_id()::xid8), prazo e atributos/versionamento. Só o owner NOLOGIN da função pode escrever/ler esse estado. Bind uma única vez por transacção; tentar rebind troca de identidade/contexto resulta em erro/rollback. Não armazenar token bruto no binding; apenas ids/atributos. Os GUCs locais são derivados dele; helper RLS compara-os com o binding privado e nega se faltarem, forem adulterados ou divergirem. A consulta RLS nunca considera GUC isolado suficiente.

Client único: BEGIN → locks/bind → SET LOCAL → autorização API → query → audit → finish_request → COMMIT/ROLLBACK → release. finish marca CLOSED e remove atributos autorizantes, preservando marcador único backend+xid8; helpers negam CLOSED e bind rejeita qualquer marcador OPEN/CLOSED já existente. Nunca apagar o marcador no finish, para impedir bind(A)→finish→bind(B). Rollback total desfaz todos os efeitos. Após commit, linha antiga não autoriza próxima transacção (xid8 diferente); job privilegiado limpa marcadores expirados/encerrados de transacções concluídas, com quota/monitorização de crescimento. Prazo 15s, transaction_timeout e limites SCC/1 impedem wrapper normal de manter locks indefinidamente. SET SESSION envenenado não cria binding na próxima transacção.

Savepoints/ROLLBACK TO não pertencem ao protocolo de request nem são expostos pelos executores. Um cliente SQL adversarial pode usá-los: rollback anterior ao primeiro bind desfaz necessariamente todos os efeitos protegidos e audit desse ramo; o novo ramo não pode conservar efeitos sob identidade anterior. Rollback posterior ao bind preserva marcador/identidade; tentativa de rebind falha. Auditar/testar estas sequências, inclusive finish rollback, para garantir que nenhum efeito sobrevivente seja associado a identidade diferente. Nenhuma função privilegiada oferece commit autónomo de efeito protegido que contorne esta regra.

## Roles e funções privilegiadas planeadas

| Identidade DB | Poder necessário / limite |
|---|---|
| migration login / object owner NOLOGIN | DDL em deployment, sem uso na API normal |
| app_runtime LOGIN | SQL protegido em transacção; EXECUTE de bind/helpers/commands exactos; sem dados de credenciais |
| auth_runtime LOGIN, pool separado | Leitura restrita de credential hash para verificação Argon2 no servidor e comandos auth; sem acesso a recursos protegidos nem mudar entitlements |
| context_owner NOLOGIN | Funções de resolução/binding; sem owner de recursos de domínio, sem superuser/bypass |
| iam_executor_owner NOLOGIN | Comandos IAM tipados, com grants/policies internas mínimas por tabela; sem superuser/bypass, sem login ou membership runtime |
| audit_writer NOLOGIN | Append por função, sem editar/remover eventos |
| test principal | Apenas TEST, efémero; provas directas também usam app_runtime real |

Credentials/sessions/context/audit também possuem RLS FORCE. Policies internas explícitas permitem apenas aos owners NOLOGIN necessários a função exacta; não aplicar recursivamente políticas de user-session à tabela que resolve essa sessão. Runtime não pode assumir esses owners. Helpers SECURITY DEFINER têm search_path fixo seguro, tabelas schema-qualified, argumentos tipados, zero SQL dinâmico, EXECUTE revogado de PUBLIC e concedido por função; funções não são declaradas LEAKPROOF. Apenas relações necessárias são concedidas aos owners, sem ownership/BYPASS implícito.

Auth pool é boundary confiável para verificar senha e emitir sessão; SQL no pool normal não pode chamar os comandos desse papel ou ler hashes. Compromisso total do processo/API ou credencial de auth é ameaça de serviço privilegiado, não uma garantia que RLS possa neutralizar. Proteger secrets, superfície SQL e auditar emissões; nunca expor hashes nas respostas.

## Boundary obrigatório de escrita IAM

app_runtime e auth_runtime não têm INSERT/UPDATE/DELETE/TRUNCATE directo sobre autoridade IAM: users, credentials, sessions, roles, permissions, user_roles, role_permissions, security_scope_refs, scope/location bindings, classifications, clearances, compartments e vínculos, incompatibilidades, approval_constraints, approvals, policy/subject state, bindings e audit. Leituras permitidas têm projecções mínimas/RLS; credential hash apenas no pool auth. Alterações só por comandos SECURITY DEFINER tipados por operação com EXECUTE explicitamente concedido. Não existe executor genérico de SQL, patch arbitrário, actor_id escolhido pelo chamador ou flag skip_checks.

Comandos IAM normais derivam actor/session exclusivamente do binding verificado, escolhem locks ADC desde início, conferem permission/grant/novo estado, delegação, SoD estática/temporal/dinâmica, invariantes administrativas, versões e auditoria na mesma transacção. O binding para mutação nunca confere permission por si. iam_executor_owner tem apenas grants e policies internas para essas funções; estas não confiam em autorizações prévias da API. SQL directo como app_runtime não pode contornar o caminho. Auth commands têm grants separados, derivam subject por lookup/token verificado e implementam estado/lockout/versões/audit; não alteram entitlements. Bootstrap tem papel/procedimento separado sem EXECUTE concedido a nenhum runtime, só estado vazio e desligado após conclusão. AUDIT append é comando especializado, sem actor/result arbitrariamente escolhidos pelo runtime como prova de sucesso.

RLS-011 futuro: DML directo em cada família IAM como ambos runtimes deve falhar, incluindo auto-grant, edição role_permissions, aprovação fabricada, redução de sensibilidade e edição audit. Invocar cada comando com actor forjado, payload proibido, approval inválida ou lock-mode indevido também falha; sucesso autorizado gera versão+audit indivisíveis. O contrato de SQL dos comandos é obrigação de implementação M1B/C/D, não enforcement alegado em M1A.

RLS-012 futuro: bind/finish/rebind negado; savepoints antes/depois do bind e finish não misturam efeitos sobreviventes/identidades; sequência de statements curtos além de 15s encerra transacção, liberta locks e não devolve client incerto ao pool.

## Provas obrigatórias futuras

Hash de token é calculado por função SHA-256 de pgcrypto, extensão provisionada apenas por migration role em schema controlado e chamada com qualificação completa; sem instalar extensões pelo runtime. Helpers usam clock_timestamp() para prazos e predicados grant-specific de RAM/1. RLS não usa apenas a união org_scope/permissions. Validade de clearance/compartimentos/grants limita o contexto; expirou qualquer requisito, nega. Helpers de decisão não são IMMUTABLE nem cacheados entre statements; nenhuma marcação de volatilidade permite reutilizar uma decisão vencida.

RLS-001 same-scope allow / cross-scope deny. RLS-002 classification allow/deny. RLS-003 compartimento completo/ausente. RLS-004 revoked/disabled/missing context deny. RLS-005 app role sem superuser/bypass/ownership. RLS-006 SET LOCAL falsificado, SET SESSION persistente, rebind e SET ROLE negados. RLS-007 pool max=1 alternando utilizadores, COMMIT/ROLLBACK/timeout/cancelamento: NO LEAK. RLS-008 UPDATE/INSERT scope/classification WITH CHECK e DELETE. RLS-009 locks/revogação concorrente conforme ADC. RLS-010 definer/search_path/views sem bypass. Testar directamente em SQL e via API.

Fixtures técnicas RLS existem somente em schemas/rotas TEST com lifecycle controlado, sem entidades patrimoniais ou organizações fictícias no produto. Em produção, o enforcement deve proteger dados IAM reais; não usar uma prova técnica para substituir RLS nas tabelas sensíveis. Nenhuma rota TEST é registada em produção.

Referências: [row security](https://www.postgresql.org/docs/17/ddl-rowsecurity.html), [funções e SECURITY DEFINER](https://www.postgresql.org/docs/17/sql-createfunction.html), [settings locais](https://www.postgresql.org/docs/17/functions-admin.html). As decisões adicionais de binding/locks são do projecto, não garantias automáticas do PostgreSQL.
