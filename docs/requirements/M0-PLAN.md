# M0-R1 — Scope, DoR and execution plan

Authority: SGP-DISPO-MASTER-v1.0-FROZEN, fully read in the original M0 execution and preserved by SHA-256 7CDE06093C1A3F0D7EF7C463BC7EE08CB4FCAC48F4B149D377166C0FF171A667. The new M0-R1 order authorises remediation, initial commit, push to the official repository and remote CI. M1 remains blocked.

## Definition of Ready

Actor: project engineering/operations team. Preconditions: existing workspace, official repository dmskalunga-rgb/SGP_PLATAFORMA, GitHub push/workflow permission, real Docker/PostgreSQL, Node/npm and a real browser. Preserve existing valid stack and migration; no reconstruction or operational data.

| Work item / requirement | Objective and rule | Security/data/API/database/audit impact | Acceptance and test expectation |
|---|---|---|---|
| GAP-M0-001/002/009 | Complete mandatory CI, integrate official main without force push | Random ephemeral CI database credentials; read-only workflow token; no business API or audit event | Initial secret-free commit/push; remote workflow result tied to exact SHA and all jobs |
| GAP-M0-003 | Correct and validate runtime containers | Non-root, read-only, no-new-privileges, no dev tools, bounded resources; no embedded credentials | Build, runtime UID/filesystem/dependency/health checks and image scans |
| GAP-M0-004/008 | SAST/SCA/secrets/SBOM; remediate seven MODERATE findings | No blanket advisory suppressions; reports redacted; no operational records | npm audit clean, versioned SAST rules, Gitleaks source/history, Trivy and CycloneDX artifacts |
| GAP-M0-005/006 | Test final migrations, live/ready and failure handling | Real PostgreSQL; temporary TEST schemas; migration DDL/checksum/rollback; technical logging only | Unit configuration tests, real integration tests, failed readiness with missing DB/schema |
| GAP-M0-007 | Validate browser baseline and backend configuration | Same-origin proxy; external upstream; no business entities or counters | Real browser render, no fatal runtime errors, real ready response and real upstream outage/retry |

No mutation of institutional data exists in M0; no audit business-event obligation is bypassed. Authentication, roles/permissions, sessions, RBAC/ABAC and functional RLS are explicitly outside this implementation. DoD applicability is recorded in traceability and test/security evidence, not waived.

## Execution and evidence

Preserve workspace; correct testability/configuration and migration validation; fix dependency chain; implement real test suites; harden images; integrate scanners and SBOM; run local gates; scan candidate tree; commit/push authorised main; run remote CI; inspect actual jobs/artifacts; review evidence and issue exactly one final gate decision. No READY_FOR_GATE claim until all required artifacts exist. Any critical failure blocks acceptance and M1. No automatic M1 or production deployment.

Official structure: apps/api, apps/web, migrations, scripts, tests/{unit,integration,frontend}, infrastructure/{docker,nginx}, docs/{adr,architecture,security,operations,requirements,evidence}, EVIDENCE. Add packages only when there is a concrete M0 responsibility; do not scaffold M1 packages.

Dependencies/risks: Docker/network/registry throughput, local Windows PowerShell compatibility, browser availability, vulnerability DB freshness, remote permissions and Actions availability. Test resources must be cleaned without touching other projects. Production TLS, backup/restore, institutional naming and later functionality remain subject to their canonical milestones.

Model strategy: recommended L1 TERRA (mechanical docs/config), L2/L3 SOL (implementation/integration/CI), L4/L5 ASTRA or highest available capacity (review/gate). Actual execution uses the current single engineering agent and independent automated local/remote test processes; no claim of a separate model review. Exact credits/tokens are not exposed. No premium-model delegation was started for boilerplate.

## Resultado M0-R1

Todos os gaps foram corrigidos e verificados no run 43006790217 ligado ao commit técnico [d966c61](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/d966c61ec280cf0aeb1e6fe739771698e98ab623). Suite final local e remota PASS, três jobs CI success, scans e quatro SBOMs preservados. Matriz formal em MILESTONE_REPORT.md. M1 permanece bloqueado por autorização, sem implementação antecipada.
