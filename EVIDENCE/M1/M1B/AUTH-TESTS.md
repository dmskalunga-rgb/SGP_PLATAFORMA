# Autenticação M1B

Fonte executável: tests/integration/authentication.test.mjs e tests/auth-browser/identity.spec.mjs. Resultados locais completos: LOCAL-TESTS.json; repetição remota obrigatória no registo indicado em CI.md. Fixtures criadas em bases TEST descartáveis; nenhum utilizador operacional seedado.

Casos: login correcto, password errada, username desconhecido, DISABLED, LOCKED; mesmo erro público sem enumeração; schemas recusam campos adicionais, username/password excessivos e Origin/CSRF inválidos. Cinco falhas activam lock, credential válida continua negada, desbloqueio autorizado permite login; tentativas não prolongam lock. Nonce consumido uma só vez e limite10/IP/60s aplicado antes de hashing. Lifecycle mínimo por comandos DB atómicos, sem self-target ou remoção dos últimos operadores. Direct SQL/runtime não acede credenciais ou bootstrap.

Browser TLS prova: bootstrap real → login → sessão persistida → logout → replay negado; operador revoga outra sessão → retry negado; falhas repetidas → lock → tentativa válida negada → eventos completos. Não são mocks de API ou de banco. React StrictMode revelou corrida de dupla emissão de nonce; uma promise por instância do componente eliminou a corrida, sem estado global de utilizador. Rate bucket foi corrigido para evitar reset na fronteira do minuto. Falhas de desenvolvimento não foram classificadas como gate PASS.
