# Foundation runbook

Start/stop: for local tests run scripts/local-tests.ps1; cleanup is in finally/trap handlers. For a provisioned local foundation, supply external environment settings and run docker compose up --build -d; inspect docker compose ps and stop with docker compose stop. Restart a selected service with docker compose restart api (or web/db). Do not delete persistent volumes as a routine restart.

Migration: use the dedicated owner connection and npm run migrate. A failure rolls back the transaction; examine database logs privately, resolve the cause and rerun without modifying applied files. Rollback of a future release requires compatibility analysis and a verified restore, not arbitrary deletion of migration rows.

Inspection: GET /health/live must return 200 when the API process is alive; GET /health/ready must return 200 only with a reachable migrated PostgreSQL. A 503 directs the operator to database reachability, credentials, grants and migration status. Logs are technical events without sensitive SQL internals. Do not print Docker environment values or connection strings into tickets.

API failure: inspect exit status and configuration names without exposing their values; restart only after resolving the cause. Database failure: preserve the data volume and logs, check service/storage capacity and connectivity, then follow the approved recovery policy. Storage failure: avoid write attempts or volume deletion until the DBA has assessed integrity. Incident: restrict access, preserve evidence, rotate exposed credentials and record the response. Certificate renewal and user recovery have no active M0 implementation: there are no users or TLS certificates provisioned here; these procedures must be supplied and validated in their authorised milestones.
