# M0-R1 security execution

Gitleaks v8.30.1 source scan completed with no leaks; output artifacts/gitleaks-worktree.json is empty. It scans the candidate repository, excluding generated dependencies/reports and disposable test credentials. History scanning must also run after the initial commit and on full-depth checkout in CI.

npm audit after typescript-eslint update and minimatch override reports zero vulnerabilities at every severity. The seven prior MODERATE occurrences and decisions are documented in M0-R1-DEPENDENCIES.md. SAST uses Semgrep with versioned rules in .semgrep.yml against application and migration source. Trivy performs complementary SCA and HIGH/CRITICAL image gates. Their final results must be recorded after completion; pending is not PASS.

Mock policy scan: zero operational matches. References in the frozen master and the scanner itself are classified as non-operational. Runtime image and CycloneDX evidence is tracked in M0-R1-CONTAINERS.md. Production TLS, credentials and institutional deployment are not supplied by this remediation.

## Reviewed secret-scan false positive

Second remote run identified only the initial public Git commit ID as sourcegraph-access-token in EVIDENCE/M0-R1-CI.md. The columns resolve to the exact already-public Git object 8f4919c6949119ae1523c4c37a1feac7d831f10d, verified against the repository commit. It is not a credential. A rule-specific allowlist matches only that exact value; no path, whole rule, commit or class of hashes is excluded. No rotation is applicable to a Git identifier. Source and history scanning remain mandatory. New cache directories are excluded as generated third-party analysis data, consistent with .gitignore.

## Second image review

The corrected API and web image HIGH/CRITICAL reports were empty. The additional PostgreSQL scan identified krb5-libs and libxslt fixes plus vulnerable Go stdlib in /usr/local/bin/gosu. The PostgreSQL image is now derived from the pinned official base, updates the two libraries to exact fixed versions and removes gosu because runtime always starts as the non-root postgres user. A new complete scan and real startup/integration suite must validate this correction; no vulnerability is ignored.
