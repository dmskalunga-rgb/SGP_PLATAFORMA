# M0-R1 remote CI

Official repository: https://github.com/dmskalunga-rgb/SGP_PLATAFORMA.git. main is configured locally as the target branch; remote was initially empty. GitHub authentication and push/workflow permission were verified. No push has yet been claimed in this evidence checkpoint.

Workflow: M0 Foundation Gate. Mandatory jobs: Foundation tests; Source security and SBOM; Container security. Actions are pinned to commit SHAs, permissions are read-only and no deploy step exists. Scans and tests fail their job on nonzero exit. Artifacts are retained for 30 days even when a job fails.

Run identifier, commit SHA, branch, job/check results and links must be filled from the actual remote execution after the authorised push. Until then Remote CI is pending and M0_GATE remains FAIL. Branch protection recommendations are in docs/operations/BRANCH-PROTECTION.md; activation is not claimed.
