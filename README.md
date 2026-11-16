# SGP-DISPO

Canonical authority: `SGP-DISPO-MASTER-v1.1-FROZEN-FINAL.md`, adopted by commit0408117. See `docs/governance/MASTER-AUTHORITY.md` and approved CR-SGP-001. The v1.0 Master is preserved as historical evidence.

M0/M1A/M1B/M1C approved foundations remain preserved. M1D IAM administration is authorized and currently a Draft PR candidate with technical validation complete and documentary gate consolidation in progress; it is not formally gate-approved until exact-SHA CI and independent review pass. M2 is BLOCKED and requires separate human authorization. This repository is an existing implementation: resume, extend, migrate forward and preserve passed gates.

The administration surface uses real API/PostgreSQL authorization, RLS, delegation, SoD and atomic audit. Read `docs/operations/M1D-IAM-ADMINISTRATION.md` for actual operations and constraints. Current evidence is in `EVIDENCE/M1/M1D/`; no production-readiness claim is made.

## Local checks

Use the Node version in `.nvmrc`, npm and Docker Desktop/Linux containers. Install with `npm ci`, then run `npm run lint`, `npm run typecheck`, `npm run build`, `npm run test:policy`. On Windows, run `powershell -NoProfile -File scripts/local-tests.ps1` with Docker access. This creates and cleans an isolated PostgreSQL TEST container, random credentials, test schemas and a real browser session (Chrome when installed). No operational seed is used. On Linux/CI, the workflow creates a disposable PostgreSQL and installs Chromium.

For a managed database, set `DATABASE_URL` privately, run `npm run migrate`, then `npm run start -w @sgp/api`. The default API bind is loopback. For the web development server use `API_UPSTREAM` to configure the backend and `npm run start -w @sgp/web`. It proxies health to the API. The production web image uses the same-origin Nginx proxy and runtime `API_UPSTREAM`.

`artifacts/` contains generated reports and is excluded from Git. Selected reviewed evidence is recorded in `EVIDENCE/` and complete CI artifacts are attached to each workflow run. Never commit `.env`, test credentials, tokens or dependency directories.
