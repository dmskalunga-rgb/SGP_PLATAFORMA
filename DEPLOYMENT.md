# M0 deployment baseline

The Dockerfiles are buildable artifacts for an internal foundation. They are not approval to deploy the final institutional system. Build with `docker build -f infrastructure/docker/api.Dockerfile -t sgp-api:m0 .` and the corresponding web Dockerfile.

Compose binds only the web port to loopback and isolates PostgreSQL on an internal network. Supply owner and runtime credentials externally; never reuse the owner URL as DATABASE_URL for the API. Have the DBA apply migrations and grant the limited runtime permissions documented in DATABASE.md before checking readiness. The web proxy uses API_UPSTREAM at runtime. VITE_API_BASE_URL can override the browser base at build time, but same-origin routing is the validated baseline.

Use separate Compose project names, volumes, networks and secret sources for each DEV/TEST/STAGING/PRODUCTION environment. The institutional production change must approve TLS termination, certificates, DNS, firewall rules, trusted proxies, secret storage, monitoring, backup/restore, image digests and resource sizing before deployment. No production credentials or institutional data are provisioned by M0.

Promotion requires the complete M0 gate, remote CI and a separate authorisation for M1. A later production release requires the canonical production gates. Images are not published by this workflow; GitHub Actions builds, tests, scans and retains evidence only. No automatic deployment occurs.
