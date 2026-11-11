# M0-R1 — rastreabilidade final

Evidência remota comum: commit técnico [d966c61](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/d966c61ec280cf0aeb1e6fe739771698e98ab623), run 43006790217, três jobs PASS. JSONs, SBOMs e SHA256SUMS.txt estão em EVIDENCE/M0-R1.

| ID | Requisito, implementação e design | Teste/evidência | Estado |
|---|---|---|---|
| SGP-M0-001 | Workspace React/Vite/Fastify, TS strict, package manifests; ADR-001 | build/lint/typecheck remotos e locais | PASS |
| SGP-M0-002 | PostgreSQL real, migration 001, runner transaccional/checksum | 2 testes migration + smoke; DATABASE.md | PASS |
| SGP-M0-003 | Configuração, logging/erros, health e OpenAPI | 2 integração + browser/proxy/outage; ERROR-MODEL.md | PASS |
| GAP-M0-001 | Workflow obrigatório com três jobs, sem deploy | M0-R1-CI.md e logs remotos, cada step conclusion | CLOSED |
| GAP-M0-002 | Execução remota oficial ligada a SHA | M0-R1-CI.md, run 43006790217 success | CLOSED |
| GAP-M0-003 | Imagens multi-stage/non-root, readonly, limites, health | container-runtime.log e smoke.log | CLOSED |
| GAP-M0-004 | Gitleaks/Semgrep/npm/Trivy e quatro SBOMs | JSONs e CycloneDX versionados | CLOSED |
| GAP-M0-005 | Harness unit/integration/database/migration/browser | 2+4+2 PASS e smoke PASS | CLOSED |
| GAP-M0-006 | Health final 200/503 real, schema e DB | integração, browser e container outage | CLOSED |
| GAP-M0-007 | API externalizada, render e erro/retry reais | Playwright, sem interceptação/mock | CLOSED |
| GAP-M0-008 | Sete MODERATE corrigidas, override dev documentado | npm-audit.json zero e triagem individual | CLOSED |
| GAP-M0-009 | origin oficial/main, commit inicial e pushes reais | histórico Git e CI commit-bound | CLOSED |
| SGP-M0-004 | Zero mock operacional | policy scan e revisão da superfície M0 | PASS |
| SGP-M0-005 | Documento canónico preservado | SHA-256 do ficheiro e do blob Git idênticos | PASS |

DoD aplicado à fundação: código frontend/backend, persistência técnica, migration/constraints, contrato health, validação, falhas/logging, testes, segurança, documentação e evidência. Elementos operacionais de IAM, autorização, RLS, auditoria de negócio e património não existem em M0 e não foram antecipados. A ausência desses módulos não foi mascarada com mocks ou interfaces fictícias.
