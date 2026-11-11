# M0-R1 security checkpoint

Fresh npm audit reports zero vulnerabilities. The seven prior MODERATE occurrences are FIXED with development-only dependency updates and a patched minimatch override. See EVIDENCE/M0-R1-DEPENDENCIES.md for compatibility impact and decisions.

Candidate worktree Gitleaks: no leaks. SAST, history scan, complementary SCA, image scans and remote CI still require completed evidence. Container build/runtime corrections are implemented but not auto-approved by their existence. Production TLS/secrets/recovery and M1 security functionality are not claimed.

No risk exception is used to turn a missing or failing critical gate into PASS.
