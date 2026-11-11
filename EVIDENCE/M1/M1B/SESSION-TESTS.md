# Sessões e contexto M1B

Testes DB/API: persistência de hash32bytes/token256bit, UUID não sequencial, flags Secure/HttpOnly/Strict/Path sem Domain, erro para token ausente/alterado/aleatório e replay pós-revogação/logout. Duplo logout idempotente. Expiração absoluta e idle reais, rotação revoga predecessor sem ampliar prazo, sessões concorrentes por identidade, revogação individual/todas/password change e comandos administrativos restritos.

Contexto: requests A/B simultâneas e pool max=1 devolvem identidade própria; objecto request.auth e grants profundamente congelados. SQL com GUCs forjados não cria autoridade; bind verificado deriva identidade da sessão, finish fecha marcador, rebind falha e rollback não deixa binding para nova transacção. Policy/subject/session locks serializam revogação e pedido anterior; novo binding após commit revogado falha. Teste real com múltiplos statements curtos excede transaction_timeout15s e confirma backend/locks libertados.

RLS interno mínimo explicitamente autorizado: FORCE/ENABLE nas tabelas IAM privadas, owners NOLOGIN e runtimes sem DML/SET ROLE privilegiado; app não lê credenciais, auth não altera entitlements. Não há RLS de negócio nem motor ABAC/classificação/compartimentos nesta fase. Campos de atributos ainda não concedidos permanecem null/[] e não dão acesso a recursos futuros.

Resultados exactos e contagem em LOCAL-TESTS.json e CI remota. As garantias contra superuser ou comprometimento total do auth service não são alegadas.
