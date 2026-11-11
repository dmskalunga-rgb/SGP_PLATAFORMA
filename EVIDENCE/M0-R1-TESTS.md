# M0-R1 tests

Fresh remediation suite: build, lint and TypeScript strict checks passed. Local real PostgreSQL tests: 2 unit + 4 integration tests passed, including persisted/idempotent migration, checksum drift rejection, DDL rollback, missing-schema readiness, connection failure, headers, request size and sanitised response. Playwright with installed Chrome: 2 browser tests passed, real API/PostgreSQL ready state and real upstream outage/retry. No intercepted/mocked API route or fabricated operational data is used.

The test runtime database account has rolsuper=false, rolcreaterole=false, rolcreatedb=false and rolbypassrls=false. Test schemas and credentials are disposable, and cleanup runs in finally/trap handlers.

Complete output: artifacts/{build,typecheck,lint,migration,tests,frontend,runtime-db-role}.log and artifacts/frontend-results.json locally; remote workflow artifacts supply the commit-bound results. Scripts/local-tests.ps1 reproduces the local suite. GitHub Actions repeats the checks on Linux with Chromium and Node from .nvmrc. Remote CI is mandatory and pending until M0-R1-CI.md records its actual result.
