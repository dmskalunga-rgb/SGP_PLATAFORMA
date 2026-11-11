# M0-R1 — testes do estado final

Resultado dos testes obrigatórios: PASS. Código validado: [d966c61](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/d966c61ec280cf0aeb1e6fe739771698e98ab623). Evidência remota: run 43006790217, job Foundation tests 130476154005. Dados de browser em EVIDENCE/M0-R1/frontend-summary.json; metadata integral dos jobs e testes nos artefactos/logs do run indicado.

| Suite | Casos e finalidade | Resultado |
|---|---|---|
| Configuração unitária | URL ausente/inválida/não PostgreSQL; porta/ambiente inválidos; bind loopback | 2 PASS |
| Migration em PostgreSQL real | Persistência e timestamp idempotente; drift de checksum e rollback de DDL/tracking em falha deliberada | 2 PASS |
| Health/API em PostgreSQL real | Banco sem schema, schema migrado, falha de ligação, live/ready, headers, tamanho de pedido e sanitização | 2 PASS |
| Browser real | Render sem erro fatal, integração API/PostgreSQL, estado vazio de módulos; outage real do upstream e retry | 2 PASS |
| Containers reais | DB/API/web iniciam, proxy pronto, utilizadores sem root, readonly, ausência de tooling dev, healthchecks, falha real do DB | PASS |
| Qualidade | Lint, TypeScript strict, build final | PASS local e remoto |

A suite local foi novamente executada com a imagem PostgreSQL final corrigida e terminou com oito testes PASS. O smoke local final também passou com UID PostgreSQL 70, API 1000 e web 101, e readiness 503 após parar PostgreSQL enquanto live continuou 200. CI repetiu a suite com Node 24.22.2, Chromium e PostgreSQL real.

Falhas de diagnóstico preservadas: a primeira imagem web não criava /tmp/conf.d em readonly e foi corrigida; uma leitura de script local alterado durante a execução foi abandonada e repetida sobre snapshot estável; uma repetição de browser sob carga concorrente excedeu o timeout e foi repetida sem scanners pesados, passando. Download local da base Trivy expirou e uma consulta Alpine teve falha TLS transitória; os scans obrigatórios foram efectivamente concluídos na CI e os relatórios estão versionados. Nenhuma falha foi convertida em PASS sem nova execução/evidência.

Não existem testes de autorização/RLS de negócio porque M1 é expressamente proibido nesta execução. Os testes não simulam PostgreSQL nem a API: dados efémeros são apenas metadados e tabelas/schema de TEST, com limpeza automática.
