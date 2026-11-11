# M0 error and logging model

Readiness uses a fixed body `{status: unavailable}` with HTTP 503 when the database/schema cannot be queried. It exposes no credentials, SQL, stack or filesystem detail. Process liveness does not depend on PostgreSQL. Unexpected request errors are sanitised to `{error: internal_error, request_id}` and HTTP 500. Framework input errors retain the 4xx status with `{error: invalid_request, request_id}`. There is no business error model in M0 because no business operation is implemented.

Technical logs are JSON. Connection errors and request failures use named technical events without raw exception or SQL data. Authorization/cookie headers are redacted. No business audit substitute is claimed. Log transport, retention and institutional monitoring must be validated in the deployment/security milestones.
