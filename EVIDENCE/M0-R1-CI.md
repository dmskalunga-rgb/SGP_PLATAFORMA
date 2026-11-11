# M0-R1 remote CI

Official main: https://github.com/dmskalunga-rgb/SGP_PLATAFORMA. Initial commit 8f4919c6949119ae1523c4c37a1feac7d831f10d was pushed successfully; no authentication or permission block occurred.

Initial run: [43004915621](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43004915621), workflow M0 Foundation Gate. Foundation tests PASSED (lint, types, build, real PostgreSQL migrations/integration and Chromium/browser). Runtime container security smoke PASSED. Overall run FAILED: Semgrep rejected the JSX raw-HTML rule syntax; Trivy blocked vulnerabilities in the Nginx base, including a CRITICAL brotli issue and HIGH curl/libexpat/libxslt/musl/zlib findings. Gitleaks source and complete Git history scans passed; npm audit reported zero.

Remediation: valid generic raw-HTML rule with the same prohibited sink, explicit patched Alpine library versions, current PostgreSQL 17 digest, scanner images pinned by digest, adequate scanner timeout. Mandatory controls were not suppressed. A new commit/run must validate these corrections before acceptance. Final run details will be recorded after actual execution.

Actions use pinned commit SHAs and read-only permissions; artifacts are retained for 30 days. There is no deployment step. Branch protection recommendations are in docs/operations/BRANCH-PROTECTION.md and are not claimed active.
