# M0 architecture

The existing npm workspace is retained: React/TypeScript/Vite in apps/web, Fastify/TypeScript in apps/api, PostgreSQL and versioned SQL migrations. No users, sessions, roles/permissions model, RBAC, ABAC, RLS functional model or asset operations are implemented.

The web baseline renders readiness based on a real API response, with loading, unavailable and retry states and an explicit absence of operational modules. It contains no operational counters or records. Browser requests are same-origin, proxied to an externally configured backend. Cross-origin access is not enabled.

Liveness concerns the process. Readiness requires a PostgreSQL query and the M0 migration version. Missing schema or connection failure gives 503 with a sanitised body. The migration runner serialises migrations using a PostgreSQL advisory transaction lock; validates checksums, duplicate versions and unknown applied versions; and executes DDL and tracking rows in one transaction. An altered applied migration fails; failures roll back.

The API is split into configuration, application factory and process entrypoint to support real integration tests. Logs contain technical events and request identifiers without exception internals or connection strings. Technical logs are not institutional audit records; there are no business mutations in M0.

Images use separate build/runtime stages. API runtime receives only production dependencies and compiled output, with npm and Yarn removed. Web runtime contains compiled assets and unprivileged Nginx. Runtime code is root-owned and readable by the non-root user. Read-only roots, dropped capabilities, no-new-privileges, PID/memory/CPU limits and healthchecks are exercised by container smoke tests. PostgreSQL runtime accounts are distinct from application IAM and are tested with minimum privileges.
