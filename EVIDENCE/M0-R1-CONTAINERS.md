# M0-R1 container evidence

API and web images built successfully locally. Node base 24.22.2 and Nginx unprivileged stable base are fixed by digest. API runtime includes production dependencies only and removes npm/Yarn; web runtime includes compiled static assets and an unprivileged proxy. Dockerfiles include healthchecks.

scripts/container-smoke.sh exercises non-root UID, dropped capabilities, no-new-privileges, read-only root, bounded resources, absent developer dependencies, real database migration and runtime role, proxied readiness and a real PostgreSQL outage (503 while live remains 200). Execution and scan results are pending until reports are complete. Image construction alone is not container acceptance.

Compose also separates database/frontend networks, supplies resource limits and binds web to loopback. It remains an M0 local baseline requiring secure external owner/runtime credentials and migration provisioning. No production deployment is authorised or claimed.
