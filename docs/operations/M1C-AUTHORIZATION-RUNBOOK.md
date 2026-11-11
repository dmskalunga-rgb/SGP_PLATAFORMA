# M1C — operação e limites de autorização

Estado de publicação: ver EVIDENCE/M1/M1C/CI.md e a atestação final associada ao commit. Este documento não declara readiness de produção nem autoriza M1D/M2.

## Deployment

Aplicar migrations 001–003 pelo canal de migration, nunca com credenciais runtime. 001/002 não foram reescritas. Verificar o master e os onze contratos com `node scripts/check-frozen.mjs`. A migration 003 cria catálogo e funções, sem identidades, organizações ou activos fictícios.

Numa instalação vazia, o bootstrap M1B recebe duas identidades reais distintas por stdin protegido. A mesma transacção inscreve esses operadores no M1C com classificação activa de menor rank explicitamente seleccionada, clearance nesse nível e delegação global IAM explícita. Não recebe clearance máxima nem compartimentos implícitos. O catálogo associado à role inicial é configuração concreta; a avaliação nunca permite acesso por nome dessa role.

Numa instalação M1B já usada, validar institucionalmente os dois operadores e invocar uma vez `iam.enroll_m1c(uuid,uuid)` pelo canal de deployment. Não está concedida aos runtimes, exige vínculos bootstrap globais permanentes e recusa repetição. Até à inscrição, atributos/metadados em falta negam acesso. Não se assume que toda identidade preexistente está autorizada: metadados de outros sujeitos exigem provisionamento controlado.

Scopes/localizações são UUIDs técnicos IAM_SCOPE. Classificações, restrições SoD, referências e delegações são configuração de autoridade pelo canal controlado de deployment; não existe endpoint para um operador editar o seu grantable_set/ceiling. Validar configuração institucional e retenção antes de qualquer deployment. A UI completa de configuração permanece M1D.

## Pedido e comando

Leituras usam o mesmo PoolClient entre BEGIN, bind_request, avaliação, RLS, audit, finish e COMMIT. O lock de policy é SHARE desde o início. Mutação usa EXCLUSIVE desde o início, bloqueia subjects e sessões em UUID order e chama um executor específico. Não promover locks; nenhuma flag de escrita confere capacidade. Os timeouts permanecem 15s/5s/2s/5s.

Role creation, conteúdo de role, assignment, clearance, compartment, approval e revogação de assignment têm funções específicas. Não há SQL/patch genérico. Roles já atribuídas não recebem alteração de permissions administrativas: configurar uma role sem membros e obter aprovação para a atribuição privilegiada. A revogação deste baseline não remove assignments administrativos; evita perda indirecta de capacidade. Comandos de estado M1B mantêm as verificações M1C e a capacidade de dois operadores.

Maker-checker usa duas identidades distintas, diferentes do alvo. Payload é normalizado por tipos PostgreSQL antes de hash, contém operação/alvo/validade/versionamento e idempotency key. Checker revalida o maker, a sessão original, grants, delegação e payload; consume uma vez na mesma transacção da concessão. Falha de auditoria desfaz tudo. Pedido de aprovação não concede entitlement nem altera policy_version. Uma alteração de policy obriga a novo pedido.

Revogação espera transacções anteriores dentro dos timeouts; após commit, novos bindings reavaliam a autoridade. Não há cancelamento retroactivo prometido. Metadados incompletos/inactivos, clearance ausente e compartimentos parciais negam.

## Auditoria e HTTP

`authorization_events` é append-only pelos executores privados, com actor/sessão/request/decision/policy e before/after sem credenciais. Leituras e contagens do endpoint audit são filtradas por RLS. Uma negação de lookup é auditada antes do 404 indistinguível. Após rollback de comando negado, um canal separado só permite append DENY, deriva actor do binding e aceita operações de catálogo fechado; nunca constitui prova de sucesso. Se o append falha, devolver 503.

401 para sessão ausente/inválida, 403 para capacidade insuficiente, 404 para objecto escondido/ausente e 503 para autoridade/auditoria indisponível. Erros internos e atributos classificados não são respostas públicas. Os requests exigem TLS, Origin e CSRF M1B.

A página de perfil oferece somente consulta de funções autorizadas. Ocultar o botão é UX; a API volta a avaliar e o PostgreSQL filtra cada linha. Não há administração IAM completa.

## Verificação e limites

`scripts/local-tests.ps1` executa bases reais efémeras e browser TLS. Os testes M1C usam fixtures técnicas apenas nas bases TEST; a tabela test_policy comprova USING/WITH CHECK, sem rota operacional. As tabelas IAM reais têm FORCE RLS, projecções de leitura protegidas e zero DML directo runtime; as escritas são verificadas pelos executores.

O auth pool continua um boundary privilegiado M1B. DBA/superuser/processo comprometido, checkpoint externo de auditoria, recuperação institucional e observabilidade de contenção precisam dos controlos de deployment apropriados. Não se alega RLS contra superuser nem imutabilidade contra DBA.

Referências primárias: [RLS PostgreSQL 17](https://www.postgresql.org/docs/17/ddl-rowsecurity.html), [SECURITY DEFINER e search_path](https://www.postgresql.org/docs/17/sql-createfunction.html), [locks](https://www.postgresql.org/docs/17/explicit-locking.html).
