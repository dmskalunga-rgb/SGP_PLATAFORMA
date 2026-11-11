# M0-R1 traceability

| Requirement/gap | Design/ADR and code | Tests/evidence | Acceptance status |
|---|---|---|---|
| SGP-M0-001 workspace/strict baseline | ADR-001, package manifests, TypeScript configs | fresh lint/types/build logs | local PASS; remote pending |
| SGP-M0-002 PostgreSQL/migration | migrations/001, scripts/migrate.mjs | real-schema integration, checksum/idempotency/rollback | local PASS; remote pending |
| SGP-M0-003 health/error/logging | apps/api/src/{config,app,index}.ts, OpenAPI | integration failures, browser and container probes | local app PASS; containers pending |
| GAP-M0-001/002 CI | .github/workflows/ci.yml | M0-R1-CI.md, remote artifacts | pending remote |
| GAP-M0-003 containers | Dockerfiles, Nginx/Compose, smoke script | M0-R1-CONTAINERS.md | pending runtime/scans |
| GAP-M0-004 SAST/SCA/secrets/SBOM | .semgrep.yml, .gitleaks.toml, workflow | M0-R1-SECURITY.md | partially executed; not approved |
| GAP-M0-005/006 tests/health | unit/integration and local test harness | M0-R1-TESTS.md | 2+4 local PASS |
| GAP-M0-007 frontend | App.tsx, Vite proxy, Playwright | 2 real browser tests PASS | local PASS; remote pending |
| GAP-M0-008 seven MODERATE findings | dependency update + override | audit zero; M0-R1-DEPENDENCIES.md | FIXED locally; remote pending |
| GAP-M0-009 official Git | official origin/main | history scan, commit/push/run evidence | pending initial push |

DoD applicability: frontend/backend/persistence/migration/constraints/health contract/logging/errors/tests/docs/evidence apply to M0. Institutional business rules, business audit, operational authorization and RLS model do not exist in M0 and are not implemented ahead of M1. No operational mock data or fake actions are introduced. Every pending critical item blocks the gate.
