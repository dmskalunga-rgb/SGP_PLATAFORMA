# M0-R1 remaining acceptance work

- Complete local SAST/SCA and container runtime/image scans; generate and validate SBOMs.
- Commit only reviewed source/evidence after secret scan, push official main, execute remote CI and capture exact SHA/run/jobs/artifacts.
- Preserve all required reports and issue one final M0 gate decision; pending checks keep M0_GATE=FAIL and M1 blocked.
- Branch protection is a recommendation pending repository configuration; it is not claimed active.
- ESLint 9.39.1 emits an unsupported-version notice; no npm advisory is reported after remediation. Track toolchain upgrade before a future major change. Fastify 5 logs a deprecation notice for disableRequestLogging; it remains supported in this pinned major.
- Production TLS, recovery targets, backup/restore and institutional deployment require the canonical later milestones and approval. These are not active production guarantees of M0.
