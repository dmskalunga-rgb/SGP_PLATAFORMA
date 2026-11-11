# Authentication and session architecture — SES/1

Estado: FROZEN/APPROVED M1A. Autenticação interna inicialmente; adaptadores AD/LDAP/OIDC/SSO/MFA futuros normalizam identidade e strength, sem implementação ou claims de integração nesta fase. Username não precisa ser email. Todas as decisões usam fonte autoritativa PostgreSQL.

## Credencial

Argon2id, salt único de pelo menos 16 bytes, hash 32 bytes, baseline m=65536 KiB/t=3/p=1; parâmetros/algorithm version guardados por credencial. Calibrar sob limites de CPU/memória antes de M1B PASS, nunca degradar silenciosamente. Concorrência de hashing limitada e rate limiting antes do hashing; rehash em login quando a política sobe. Password 15–128 codepoints, Unicode NFC declarado, sem truncar silenciosamente nem armazenar reversivelmente; lista local controlada de passwords comuns/comprometidas. Nunca SHA simples para senha. SHA-256 só é adequado aqui ao token de sessão aleatório de alta entropia.

Lookup/verificação via auth_runtime separado: receber hash apenas no servidor, validar Argon2 fora da transacção longa; finalizar login sob lock exclusivo do subject, revalidando credential_version/status e lockout antes de criar sessão. Troca de senha/estado concorrente invalida o resultado. Utilizador desconhecido faz verificação de hash de custo equivalente e erro genérico; não enumerar contas em status/body. Registar falhas sem password ou username sensível em logs técnicos; auditoria tem referência/pseudónimo controlado.

5 falhas por conta em 15min activam LOCKED automático por 15min; LOCKED administrativo não expira automaticamente. Conta DISABLED/INACTIVE nunca se reactiva por timeout. Rate limit inicial: 10 tentativas/IP/minuto, 5 falhas/conta/15min, limites globais de hashing e por rota; não confiar em X-Forwarded-For não verificado. Valores versionados, testes de bypass e DOS exigidos. Erro genérico para senha inválida/conta inexistente/bloqueada/desactivada; indisponibilidade de banco/audit resulta em 503 sem sessão.

## Sessão e transporte

Token opaco CSPRNG 32 bytes (256 bits), sem claims institucionais. Banco guarda apenas SHA-256 do token, ids, tempos, estado/revoked_at/reason, credential_version e metadados de risco mínimos. Não usar JWT stateless, localStorage ou token completo em UI/log/audit. bind_request recebe o token bruto por parâmetro seguro e faz o hash; um hash obtido de snapshot não é aceite como token. Proteger parâmetros contra logging SQL (log_parameter_max_length e on_error=0), traces e dumps. Ligação institucional TLS validada.

Cookie __Host-sgp_session: Secure, HttpOnly, Path=/, sem Domain, SameSite=Strict; tempo do cookie não amplia validade DB. Login e todas as mutações exigem Origin exacto e protecção CSRF synchronizer token ligado à sessão, enviado por header; comparação constante. Login usa nonce pré-autenticação de curta duração, ligado ao browser/origin e consumido uma vez, sem criar identidade autenticada. GET não altera estado sensível. TLS é requisito de autenticação, inclusive browser E2E com certificado TEST efémero; não criar bypass de cookie/CSRF em produção. Proxy strip/overwrite Forwarded, trustProxy limitado a rede autorizada, nunca trust=true universal.

Absolute timeout 8h; idle 15min; refresh/rotação não estende absolute deadline. Rotação em login, mudança de força/credencial e endpoint explícito de rotação autenticado+CSRF, nunca rotação automática em cada request concorrente. Substituição atómica: antigo revogado e novo hash criado; sem grace window para token antigo. Requests em voo podem falhar e devem reautenticar/recarregar; não recuperar sessão com token revogado. Sessões guardam timestamps do DB, não relógio do browser. Desactivar, lock administrativo, password reset/change e força-logout revogam todas as sessões do alvo atomicamente.

Resolução/idle e revogação seguem locks e linearização ADC/1: nenhuma nova transacção após commit de revogação pode usar a sessão antiga. Não alegar cancelamento retroactivo de operação concluída. Logout é POST idempotente com protecção de origem; cookie é limpo e sessão revogada, sem excluir histórico. Sessões expiradas são conservadas conforme retenção controlada, nunca reactivadas por clock cliente.

## Contratos HTTP a implementar apenas em M1B/D

Nonce de login: 256 bits CSPRNG, TTL 5min, hash no banco, uso único e quota por origem/IP. Cookie pré-auth __Host-sgp_preauth Secure/HttpOnly/SameSite=Strict/Path=/ liga browser ao nonce; o formulário recebe valor CSRF distinto associado no servidor. POST valida Origin, cookie e header antes de consumir atomicamente o nonce; refresh exige novo nonce. Remover após uso/expiração. Nenhum valor pré-auth concede autoridade. Logout/rotate/change-password usam transacção de mutação exclusiva desde o início conforme ADC/1; nonce e sessões têm limpeza/quotas para limitar abuso.

/api/v1/auth/login, logout, session, rotate, change-password; operações de admin sessions/users/roles/clearances/compartments/audit paginadas em M1D. /login, /logout, /session-expired, /access-denied são páginas reais futuras, sem fake actions. OpenAPI actual de M0 não é alterada em M1A. Nenhuma senha/token/credential hash é resposta de endpoint.

## Auditoria e bootstrap

LOGIN_SUCCESS/FAILURE, SESSION_CREATED/REVOKED, LOGOUT, ACCOUNT_LOCKED/UNLOCKED, PASSWORD_CHANGED e RESET quando existir. Sessão só é emitida depois de commit com auditoria; falha de audit faz rollback. Password/reset não usam segredos estáticos nem recovery backdoor. Bootstrap é procedimento separado, explícito, auditado e permitido apenas no estado inicial vazio sob lock; operador fornece identidades reais e segredos por canal protegido, sem contas seed/default. Privileged maker-checker requer dois operadores reais distintos; não permitir que o primeiro admin aprove a sua própria concessão. Recuperação de emergência exige procedimento institucional e nova evidência, não bypass automático.

Referências de controlo: [OWASP sessão](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html), [OWASP armazenamento de password](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html). Prazos/limites acima são decisões iniciais explícitas do projecto e devem ser testados no ambiente M1B.
