# SGP-DISPO — M0 foundation

Authority: `SGP-DISPO-MASTER-v1.0-FROZEN.md` (unchanged). Only M0 and remediation M0-R1 are authorised. M1 is blocked. The current gate decision is recorded in MILESTONE_REPORT.md; this baseline is not the complete institutional system.

## Local checks

Use the Node version in `.nvmrc`, npm and Docker Desktop/Linux containers. Install with `npm ci`, then run `npm run lint`, `npm run typecheck`, `npm run build`, `npm run test:policy`. On Windows, run `powershell -NoProfile -File scripts/local-tests.ps1` with Docker access. This creates and cleans an isolated PostgreSQL TEST container, random credentials, test schemas and a real browser session (Chrome when installed). No operational seed is used. On Linux/CI, the workflow creates a disposable PostgreSQL and installs Chromium.

For a managed database, set `DATABASE_URL` privately, run `npm run migrate`, then `npm run start -w @sgp/api`. The default API bind is loopback. For the web development server use `API_UPSTREAM` to configure the backend and `npm run start -w @sgp/web`. It proxies health to the API. The production web image uses the same-origin Nginx proxy and runtime `API_UPSTREAM`.

`artifacts/` contains generated reports and is excluded from Git. Selected reviewed evidence is recorded in `EVIDENCE/` and complete CI artifacts are attached to each workflow run. Never commit `.env`, test credentials, tokens or dependency directories.
