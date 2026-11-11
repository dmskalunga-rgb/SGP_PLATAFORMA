# SECURITY CONTEXT CONTRACT — SCC/1

Estado: FROZEN/APPROVED M1A, sujeito a revisão independente e gate. Normativo para a implementação futura M1B/C/D; nenhuma implementação é alegada. Fonte canónica: master FROZEN. Erro, atributo ausente, versão desconhecida ou indisponibilidade de autoridade resultam em DENY.

## Identidade e separação de conceitos

Identity = user_id UUID imutável, username (identificador, não email obrigatório), display_name, status ACTIVE/INACTIVE/LOCKED/DISABLED, authentication_source INTERNAL inicialmente, personnel_reference opcional. Username é ASCII normalizado lowercase, 3–64 caracteres [a-z0-9._-], UNIQUE; display_name Unicode não é chave. Não apagar identidades para retirar acesso. Provider subject futuro é uma ligação separada (provider_id, external_subject) UNIQUE, sem usar email como chave automática.

Role agrega permissions; permission é uma capacidade exacta; attribute é um facto autoritativo; clearance é habilitação; compartment é need-to-know explícito; organizational scope é conjunto de referências autorizadas; session é prova revogável de autenticação. Nenhum é sinónimo dos restantes.

## Envelope de contexto, por pedido

| Campo | Tipo e origem confiável | Semântica |
|---|---|---|
| contract_version | SCC/1 | Rejeitar versões desconhecidas |
| user_id, session_id | UUID, resolução DB da sessão | Nunca do body/header de identidade |
| roles, permissions | conjuntos de códigos activos, DB | União de roles activas; sem wildcard implícito |
| effective_grants | tuples permission/assignment/scope/location/validade, DB | Autoridade preserva scope de cada concessão; nunca produto cartesiano dos resumos |
| org_unit_id | UUID ou null, vínculo primário DB | null não concede scope |
| org_scope | conjunto de UUIDs, vínculos DB | Scope de segurança opaco, não hierarquia M2 |
| location_scope | conjunto de UUIDs DB | Vazio nega recurso que exija localização |
| clearance_level | id + rank parametrizado DB | Ausente não acede a recurso classificado |
| compartments | conjunto de UUIDs activos DB | Todos os compartimentos exigidos devem existir |
| authentication_strength | PASSWORD inicialmente | Requisitos superiores não satisfeitos implicitamente |
| session_created_at, session_expires_at, idle_expires_at | UTC DB | Sessão expirada é inválida; sem cache permissiva |
| credential_version, subject_version, policy_version | inteiros monotónicos DB | Invalidar identidade/sessão/contexto quando divergirem |
| request_id, correlation_id | UUIDs gerados/validados no servidor | Correlação, nunca credenciais ou autorização |
| context_binding | id interno de transacção/backend DB | Não enviado ao browser; ver RLS-DESIGN |

Objecto Fastify é imutável e criado após resolver a sessão. Não é guardado em variável global/process.env, singleton mutável ou conexão partilhada fora da transacção. O browser recebe apenas perfil mínimo e capacidades de apresentação necessárias; nunca prova de sessão, binding ou autoridade para alterar atributos. Alterações a body/cookies/headers com claims de role/clearance/scope são ignoradas como autoridade e rejeitadas quando não previstas no contrato de entrada.

## Fluxo obrigatório

Cookie opaco → BEGIN READ COMMITTED no mesmo client do pool → locks e resolução DB autoritativa → binding verificado → Fastify request context → authorize → query parametrizada com RLS → auditoria → finish/COMMIT ou ROLLBACK → release. Não usar pool.query separado entre binding e query. GUCs app.user_id/session_id/org_unit_id/clearance/compartments são SET LOCAL derivados do binding; não constituem prova independente. O contexto DB privado é a autoridade e alterações aos GUCs provocam DENY.

O contexto expira no fim da transacção; prazo máximo 15 segundos, transaction_timeout PostgreSQL 17 de 15s, statement_timeout 5s, lock_timeout 2s e idle_in_transaction_session_timeout 5s como baseline inicial sujeita a medições. O wrapper de pedido aplica também deadline total 15s, cancelamento/rollback e descarta o client se conclusão ficar incerta. Testar sequência de statements curtos que exceda o prazo total: deve libertar locks. Settings editáveis pelo runtime não são defesa de disponibilidade contra uma credencial DB comprometida; validade wall-clock do binding continua a negar acesso mesmo se settings forem alterados. Não carregar contexto para uma fila/job fora da sessão: um futuro serviço exige principal e política próprios, não impersonação silenciosa.

## Invariantes e testes a implementar

SGP-CTX-001: identidade/atributos só de autoridades DB. CTX-002: client pinning e SET LOCAL. CTX-003: zero leak em COMMIT, ROLLBACK, cancelamento, timeout e client reutilizado com GUC envenenado. CTX-004: revogação/versionamento por transacção, sem snapshot permissivo entre requests. CTX-005: ausência de contexto privado nega mesmo que GUCs aparentem identidade válida. Testes são obrigações M1B/C, não resultados M1A.
