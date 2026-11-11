# M1B — DoR e plano de execução

Estado: IN_PROGRESS. Base: M1A publicado no commit ligado em EVIDENCE/M1/M1A/PUBLICATION.md e nota Git de publicação, CI 43019324857 PASS. Autoridade: master intacto e onze contratos/ADRs M1A FROZEN. Ordem actual: M1B apenas. Clarificação explícita do operador nesta conversa: autorizado apenas RLS interno mínimo exigido por M1A; motores RBAC/ABAC e RLS de negócio permanecem M1C bloqueado.

Objectivo/actor: autenticação interna e sessões institucionais reais para utilizador e operador autorizado, com PostgreSQL, auditoria e UI real. Preconditions: hashes M1A/master exactos, M0 PASS, DB TEST descartável, TLS e secrets externos. Requisitos: ordem M1B §§3–55 e SES/SCC/ADC/RLS congelados. Não alterar ficheiros FROZEN.

Dados: identities, credentials, sessions, auth events, nonce/rate state, contexto transaccional privado; schema de roles/permissions/classificações/clearances/compartimentos necessário, sem CRUD/admin UI ou enforcement de negócio. API: nonce/login/logout/current-session/rotate/change-password e comandos mínimos de segurança de conta/sessão, schemas de entrada/saída e OpenAPI. Sem reset remoto até fluxo autorizado; fundamento é versionamento/revogação e auditoria, não endpoint fictício.

Regras: Argon2id baseline medida, senha NFC 15–128, sem hash simples; token opaco256bit só hash DB; cookies __Host Secure HttpOnly Strict e TLS inclusive TEST; Origin e CSRF; nonce pré-auth consumido uma vez; 8h absoluto/15min idle; revogação e mudanças com locks ADC desde início, transacções limitadas; erros fail-closed; zero secrets em logs. Runtimes distintos app/auth sem DML IAM, funções tipadas com NOLOGIN owners e FORCE RLS interno. Contexto imutável por request/client pinned, sem globals de identidade. Bootstrap vazio de duas identidades reais, auditado e de uso único, sem seed fake. Fixtures apenas TEST com destruição.

Auditoria: LOGIN_SUCCESS/FAILURE, SESSION_CREATED/EXPIRED/REVOKED, LOGOUT, ACCOUNT_LOCKED/UNLOCKED, PASSWORD_CHANGED; mutações+audit atómicas, rollback se falhar. Lifecycle ACTIVE/INACTIVE/LOCKED/DISABLED sem delete e auto-unlock só lock temporário.

Aceitação/DoD: matriz integral M1B com PostgreSQL/migrations/credenciais/sessões/contexto/audit/bootstrap/UI/API/DB/browser e scans PASS, regressão M0 preservada, hashes congelados exactos, CI remota no SHA publicado, evidências obrigatórias. Plano: hash guard+password/calibração; migrations/commands+DB privileges; API+UI/TLS; testes positivos/negativos/concurrency; scans/build/CI; evidências/gate; STOP antes de M1C. Sem declaração PASS local ou PRODUCTION_READY.

Modelos: elaboração pela sessão principal; sem routing fictício. Revisão ASTRA não requerida para implementação ordinária M1B. Riscos: fronteira auth privilegiada, custo hashing/quotas, contenção locks, TLS/secrets institucionais e recuperação sem backdoor. Mudança estrutural não coberta exige CR, não alteração unilateral dos contratos.
