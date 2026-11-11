# ADR-010 — PostgreSQL RLS Context

Estado: APPROVED/FROZEN M1A. Data: 2026-11-11.

Contexto: custom GUCs são modificáveis pelo runtime. FORCE RLS não torna GUC arbitrário confiável e owners/superusers têm privilégios distintos. Pool reuse exige isolamento por transacção.

Decisão: RLS/1. ENABLE/FORCE nas relações sensíveis; USING/WITH CHECK por comando. app_runtime sem ownership/superuser/BYPASSRLS/DDL/TRUNCATE/membership privilegiada. bind_request verifica token bruto contra hash calculado em schema controlado, deriva autoridade DB sob ADC locks e cria binding privado (backend PID, xid8), único por transacção. Helpers SECURITY DEFINER mínimos com search_path fixo, nomes qualificados, grants exactos, PUBLIC revogado, sem SQL dinâmico/LEAKPROOF, owners NOLOGIN sem ownership de domínio. RLS verifica binding, prazo wall-clock e correspondência dos GUCs; grants preservam scopes. Relações de segurança internas têm policies explícitas sem recursão de resolução de sessão.

Separar migration, app, auth, context owner, audit writer e test principals. Auth é boundary privilegiado restrito, nunca usado para SQL de domínio. Finish conserva marcador CLOSED sem autoridade até limpeza privilegiada após transacção; rejeitar rebind mesmo após finish. Rollback desfaz ramo/efeitos; nenhum efeito protegido/audit sobrevivente pode misturar identidades via savepoint. Linha de xid8 anterior não autentica transacção seguinte. Pool pinning, transaction_timeout 15s e limites de lock/statement/idle, deadline wrapper e descarte de client incerto são obrigatórios. Settings runtime não são fronteira anti-DOS contra credencial comprometida. Views usam identidade invoker e testes de bypass. RLS-012 cobre lifecycle/savepoints/deadline.

Adicionar iam_executor_owner NOLOGIN para comandos IAM por operação, sem DML directo em tabelas de autoridade por app/auth. Cada comando impõe autorização/SoD/locks/versionamento/audit no banco; binding ou permission de scope isolada não confere direito de edição arbitrária. Bootstrap é comando separado sem acesso runtime. Teste RLS-011 prova negação de DML directo e de comandos manipulados, além de RLS-001–010.

Alternativas rejeitadas: SET LOCAL como autenticação; SET SESSION; app owner; superuser runtime; assinatura derivada apenas de user_id informado; teste RLS apenas por API; tabelas fictícias como substituto de RLS de dados reais.

Consequências: complexidade de funções/bindings precisa de SQL real, testes adversariais e revisão antes de M1C PASS. Não proteger contra DBA/superuser ou comprometimento total do auth service; auditoria externa exige política institucional posterior. Obrigações futuras RLS-001–010, sem implementação em M1A.
