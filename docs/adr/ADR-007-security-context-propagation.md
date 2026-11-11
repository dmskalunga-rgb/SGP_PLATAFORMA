# ADR-007 — Security Context Propagation

Estado: APPROVED/FROZEN M1A. Data: 2026-11-11. Escopo exclusivamente arquitectura.

Contexto: identidade recebida por HTTP e conexão reciclada não são contexto confiável. Atributos e grants precisam permanecer coerentes até RLS/auditoria, sem estado global ou scope ampliado por união de roles.

Decisão: adoptar SCC/1, RAM/1 e RLS/1. Cookie opaco é resolvido no PostgreSQL dentro de uma transacção READ COMMITTED num client pinned. Contexto Fastify imutável por pedido contém identidade, sessão, atributos, versões, effective_grants vinculados ao scope de cada assignment e correlação. GUCs SET LOCAL são derivados do binding privado verificado, nunca raiz de confiança. Apenas helpers autorizados podem criar binding; ausência, divergência, expiração ou erro nega. BEGIN precede resolução e locks. Queries fora desse client não herdam contexto. Finish/rollback precede release; binding liga backend e xid8.

Alternativas rejeitadas: claims do frontend; singleton global; SET SESSION; usar apenas app.user_id como identidade; produto cartesiano de permissions e scopes; cache permissiva entre pedidos.

Consequências: exige funções privilegiadas pequenas, pool disciplinado e testes de reutilização/rollback/poisoning. Prazo de binding 15s e limites de statement/locks requerem medição futura. Processos de fundo não podem reutilizar sessões de utilizador implicitamente.

Validação futura: CTX-001–005, RLS-006/007. Critério documental M1A: coerência de SCC/RLS/ADC e revisão independente. Não constitui prova de enforcement executado. Mudança requer nova revisão e gate.
