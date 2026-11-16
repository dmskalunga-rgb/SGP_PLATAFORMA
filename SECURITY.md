# Security baseline and reporting

The gate blocks on secrets, operational mock data, vulnerable dependencies, failing SAST rules and HIGH/CRITICAL image findings. Gitleaks scans source and Git history with redacted reports; Semgrep uses versioned rules in .semgrep.yml; npm audit and Trivy supply SCA; Trivy scans runtime images and produces CycloneDX SBOMs. Findings are not suppressed through blanket ignores.

Health endpoints contain no institutional data and are the only application API surface. There is no authenticated or authorised operational API. Fastify applies secure headers, bounded request body and timeouts, sanitised errors and no permissive CORS. API binds to loopback by default. The Nginx baseline adds CSP and other secure headers. Production TLS and network ACL enforcement belong to the reviewed institutional deployment and are not claimed as active on this local baseline.

Credentials are supplied externally. DEV, TEST, STAGING and PRODUCTION must use separate databases, secrets, accounts, storage and network policy. Only TEST/CI scripts create disposable credentials or test schemas; their lifecycle is automatic and no institutional data is seeded. Migrations use the owner account; runtime must have no superuser, role creation, database creation or RLS bypass privileges. M0 runtime needs only CONNECT, schema USAGE and SELECT on schema_migrations.

Report a suspected exposure privately to the repository maintainers; do not include tokens or sensitive institutional content in public issues. Preserve evidence, revoke/rotate affected credentials, remove exposed history only through an authorised recovery plan and rerun all gates. This document does not assert completion of later security milestones.


## M1D IAM administration

Incremental migration 005 adds typed identity creation, role state, attribute revocation, approval dispatch/rejection and protected inbox reads. Published migrations 001–004 and M1A contracts remain unchanged. Runtimes retain zero direct IAM DML; private owners, fixed search_path, policy-first locks, delegation/SoD and atomic audit apply. User creation stores only an Argon2id hash meeting the frozen bounds; no credential or session material is returned. Existing grant, clearance temporal approval and account/session executors are reused. See docs/operations/M1D-IAM-ADMINISTRATION.md and OpenAPI for implemented routes, operational constraints and error handling. M2 remains blocked.
