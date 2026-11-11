# M0-R1 container evidence

API and web images built successfully locally. Node base 24.22.2 and Nginx unprivileged stable base are fixed by digest. API runtime includes production dependencies only and removes npm/Yarn; web runtime includes compiled static assets and an unprivileged proxy. Dockerfiles include healthchecks.

scripts/container-smoke.sh exercises non-root UID, dropped capabilities, no-new-privileges, read-only root, bounded resources, absent developer dependencies, real database migration and runtime role, proxied readiness and a real PostgreSQL outage (503 while live remains 200). Execution and scan results are pending until reports are complete. Image construction alone is not container acceptance.

Compose also separates database/frontend networks, supplies resource limits and binds web to loopback. It remains an M0 local baseline requiring secure external owner/runtime credentials and migration provisioning. No production deployment is authorised or claimed.

## Findings and remediation

The first local readonly web runtime could not generate its proxy config; a non-root pre-entrypoint creates /tmp/conf.d before envsubst. After correction, local smoke passed with PostgreSQL UID 70, API UID 1000 and web UID 101, readonly roots, cap-drop, no-new-privileges, no API development tooling, real proxied readiness and real database outage 503. The same smoke passed in initial remote CI.

Initial remote API image HIGH/CRITICAL scan was clean. Web scan blocked CVE-2026-111497 (brotli, CRITICAL), CVE-2026-92392 (curl/libcurl), CVE-2026-113351/115506/117610/118370 (libexpat), CVE-2026-87636/9947 (libxslt), CVE-2026-107891 (musl/musl-utils) and CVE-2026-85091 (zlib), all HIGH. Explicit corrected versions are pinned in the web Dockerfile; zlib 1.4-r0 supersedes the minimum advisory fix because the older minimum was unavailable in the package repository. New scans must prove the result. PostgreSQL is also moved to an updated digest and included in image/SBOM checks.
