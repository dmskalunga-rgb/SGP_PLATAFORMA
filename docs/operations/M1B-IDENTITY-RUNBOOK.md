# M1B — operação de identidade e sessão

Só M1B: autenticação e comandos mínimos de conta/sessão. Não existe administração de roles/permissions/clearances/compartimentos, nem motor RBAC/ABAC/RLS de negócio. O operador autorizou explicitamente o RLS interno mínimo exigido pelo M1A; contratos congelados não foram alterados.

## Provisionamento

Aplicar migrations pelo papel de deployment, nunca pelo runtime. 002 cria schema iam/iam_crypto, extensão pgcrypto, identidades técnicas, tabelas e funções restritas. app_runtime/auth_runtime são logins sem password inicial: provisionar passwords aleatórias externamente por administrador DB e guardar em secrets institucionais. Nunca usar o owner/migration role na API. Owners de tabelas/funções são NOLOGIN, sem superuser/BYPASSRLS. Ambos runtimes sem DML directo IAM e sem membership privilegiada.

DATABASE_URL aponta para app_runtime e AUTH_DATABASE_URL para auth_runtime. AUTH_ORIGIN é a origem HTTPS exacta, sem path/trailing slash. Produção/staging exigem sslmode=verify-full em ambas URLs PostgreSQL, com CA confiável; configurar a cadeia de confiança do Node/pg, nunca desactivar validação TLS. Antes de emitir tokens, a API verifica flags e nome dos dois papéis DB. Sem AUTH_DATABASE_URL, só a fundação/health M0 é registada; não existe login permissivo alternativo.

Terminar TLS no gateway institucional, certificados/chaves externos e lidos pelo UID apropriado. O template infrastructure/nginx/auth-tls.conf.template pode ser montado em /etc/nginx/templates/auth-tls.conf.template; montar certificado/chave em /run/secrets/sgp_tls_cert e sgp_tls_key, somente leitura, e publicar 8443 por HTTPS. Nginx substitui X-Forwarded-Proto e X-Forwarded-For e remove Forwarded. AUTH_TRUSTED_PROXY_IPS admite só IPs explícitos do gateway, com acesso directo à API limitado por rede. Não confiar universalmente em proxy. API também suporta TLS_CERT_FILE/TLS_KEY_FILE para TLS directo. HTTP de autenticação é recusado; não desligar Secure/CSRF para DEV. Vite DEV/TEST aceita WEB_TLS_CERT_FILE/WEB_TLS_KEY_FILE; certificados efémeros de TEST não vão a produção.

PostgreSQL: log_parameter_max_length=0, log_parameter_max_length_on_error=0 e sem logging de statements/binds sensíveis. As funções recebem prova opaca por parâmetro, nunca concatenar secrets no SQL. Limitar acessos a traces/dumps. DB logs não substituem authentication_events. Reservar memória para hashing: 64MiB por hash e concorrência inicial 2 por processo; considerar pools, réplicas e sobrecarga. Não baixar parâmetros para esconder falta de capacidade.

## Bootstrap

Executar node scripts/bootstrap-identity.mjs com BOOTSTRAP_DATABASE_URL do papel de deployment e stdin protegido contendo array de duas identidades reais distintas: username, display_name, password. Não colocar JSON/segredos em argumentos, histórico de shell, Git ou documentação. Usar canal de secrets/pipe protegido; não publicar ficheiro de exemplo com credenciais. Username ASCII lowercase 3–64; senha Unicode NFC 15–128 conforme política. O comando gera Argon2id e invoca iam.bootstrap numa operação atómica; recusa DB não vazio ou bootstrap_completed, não emite sessão nem password. Runtime não pode invocar bootstrap. Remover a credencial de deployment do ambiente após execução. Recuperação não oferece override/backdoor; exige procedimento institucional separado.

O bootstrap inicial atribui somente o papel técnico de operador de segurança e cinco capacidades de conta/sessão IAM global, sem clearance máximo ou compartments. Duas identidades distintas preservam a fundação maker-checker; nenhuma concessão privilegiada posterior é implementada. Operadores não podem desactivar/lock manualmente os últimos dois operadores utilizáveis nem actuar sobre si pelos comandos administrativos. Lockout automático continua fail-closed e não é impedido por essa invariável.

## Sessões e incidentes

Token opaco256bit só no cookie __Host-sgp_session (Secure/HttpOnly/Strict/Path=/), hash SHA-256 no banco; sem JWT/localStorage. Nonce de login TTL5min, cookie __Host-sgp_preauth, CSRF distinto derivado com domínio e guardado por hash, consumo único e quota. Mutações requerem Origin exacto e CSRF ligado ao bearer; comparação constante na API. Sessão absoluta8h/idle15min, rotação explícita não estende deadline, token anterior revogado sem grace.

Comandos mínimos em POST /api/v1/auth/admin/account-command: REVOKE_ONE/REVOKE_ALL/ACTIVE/INACTIVE/LOCKED/DISABLED, alvo UUID e session_id quando REVOKE_ONE. Exigem sessão activa, CSRF e capability IAM_GLOBAL exacta, validada no banco; sem auto-alvo. Não há UI administrativa fictícia ou endpoint de atribuição de entitlement. PASSWORD_CHANGED é self-service autenticado e revoga todas as sessões. Reset administrativo está reservado a fluxo institucional autorizado posterior, sem endpoint ou segredo estático nesta entrega.

5 falhas/conta em15min: lock AUTO por15min, sem prolongar por novas tentativas. Lock MANUAL não expira; INACTIVE/DISABLED não se reactivam por timeout. Rate10/IP por janela de60s ancorada na primeira tentativa (não no minuto do relógio), nonce20/IP/60s, máximo10000 nonces pendentes e hashing bounded sem fila ilimitada. Quotas DB partilhadas entre processos. Ataque dirigido ainda pode provocar lock temporário; monitorizar e aplicar controlo de rede institucional. Não remover a protecção para resolver indisponibilidade.

Revogação segue policy lock exclusivo → subjects ordenados → sessions ordenadas. Pedidos normais policy SHARE e sessão UPDATE. Commit de revogação aguarda operações anteriores; novas transacções não aceitam token revogado. Sem promessa de cancelamento retroactivo. Transaction timeout15s, statement5s, lock2s, idle-in-transaction5s e deadline do wrapper; conexão incerta descartada. finish conserva marcador CLOSED, proíbe rebind; nova transacção limpa marcadores antigos do mesmo backend e órfãos sem backend activo. Não reutilizar contexto fora da request.

## Auditoria, validação e limites

authentication_events é append-only para runtimes; sucesso de login/sessão/mudança com audit atómico, falha de append causa rollback/503. Logs técnicos só evento/request_id/correlation_id/status, sem corpo/credenciais/cookies. Não imprimir tokens, hashes ou URLs protegidas em diagnósticos. DBA/superuser continua actor privilegiado fora da protecção RLS; retenção/cópia externa e aceitação institucional permanecem obrigações de produção.

Validar node scripts/check-frozen.mjs e npm run lint/typecheck/build. scripts/local-tests.ps1 executa DB descartável, suites M0/M1B e TLS browser; CI replica em Linux. TEST cria identidades efémeras identificáveis e destrói bases/containers. Nunca executar prepare-auth-browser/provision-auth-test fora de TEST. Não declarar M1B PASS sem CI do SHA publicado e todos os scans. M1C/M1D/M2 continuam bloqueados.
