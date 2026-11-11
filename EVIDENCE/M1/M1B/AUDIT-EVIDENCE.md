# Auditoria de autenticação

Tabela iam.authentication_events, append apenas por função privada do owner NOLOGIN sgp_audit_writer; runtime sem SELECT/DML/TRUNCATE directo. Campos: actor/target/session refs, tempo DB, IP, device limitado, request/correlation UUID do servidor, event/result/reason e estados antes/depois de lifecycle. Sem password, PHC, bearer/CSRF ou URL com credenciais. Device é categoria limitada do cliente, não prova forense de equipamento.

Eventos implementados: LOGIN_SUCCESS/FAILURE, SESSION_CREATED/EXPIRED/REVOKED, LOGOUT, ACCOUNT_LOCKED/UNLOCKED, PASSWORD_CHANGED, ACCOUNT_STATE_CHANGED e BOOTSTRAP_COMPLETED. Reset events não são emitidos porque reset remoto não existe. Ordem/atomicidade: operações sensíveis e audit no mesmo commit; falha de append faz rollback/503. Teste retira INSERT do writer em TEST e prova que login não persiste sessão nem publica sucesso; permissão é restaurada em finally.

E2E lockout consulta eventos no banco real e reconstrói pelo menos seis LOGIN_FAILURE e ACCOUNT_LOCKED. Logout/revogação/mudança de password têm actor/target e motivo fixos, sem evento de sucesso fabricável pelo app_runtime. Logs técnicos são separados, sanitizados e testados por captura do logger real. PostgreSQL de TEST desliga logging de parâmetros/statement de erro; runbook exige o mesmo controlo institucional.

RLS/append-only não prometem imutabilidade contra DBA/superuser ou credential de deployment. Retenção, cópia externa e integração SIEM requerem decisões institucionais posteriores; isso não é apresentado como controlo operacional já implantado.
