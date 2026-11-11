# Evidência de execução local

Data: 2026-11-11, África/Luanda.

- SHA-256 do documento canónico: 7CDE06093C1A3F0D7EF7C463BC7EE08CB4FCAC48F4B149D377166C0FF171A667.
- Node v24.14.0; npm 11.9.0; Docker server 29.4.0.
- `git init -b main`: repositório inicializado sem commits.
- `docker pull postgres:17.7-alpine`: digest sha256:bb377b7239d2774ac8cc76f481596ce96c5a6b5e9d141f6d0a0ee371a6e7c0f2. Container de TEST isolado iniciou.
- `npm run migrate`: 001 applied or already present; `npm test`: 1 PASS, 0 FAIL.
- `GET /health/live` 200, `/health/ready` 200, web 200; readiness com base inacessível 503. Ensaios anteriores à actualização Fastify/Vite.
- Após actualização: build, typecheck, lint saíram com código 0; `npm audit --audit-level=high` código 0 e sete moderadas.
- Primeiro build antes da instalação npm terminar falhou por ferramentas ausentes; repetição posterior passou. Primeira tentativa de migration coincidiu com inicialização PostgreSQL e falhou; repetição passou. Docker build interrompido após mudança das dependências, sem resultado final.

Evidência resumida de saídas observadas; não substitui execução CI, análise independente ou scan.

## M0-R1 remediation

The original record above remains historical. Fresh results, official remote integration and the final decision are tracked in M0-R1-CI.md, M0-R1-TESTS.md, M0-R1-SECURITY.md, M0-R1-CONTAINERS.md and M0-R1-DEPENDENCIES.md. The frozen master hash remains unchanged.
