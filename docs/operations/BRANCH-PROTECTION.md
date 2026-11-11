# Recommended main protection

Recommended required checks: Foundation tests, Source security and SBOM, Container security (workflow M0 Foundation Gate). Require a reviewed pull request, disallow force pushes and branch deletion, require current checks on the final commit and retain the workflow artifacts. Apply exemptions only through institutional change control.

This remediation does not claim branch protection is enabled. The repository configuration and plan capabilities must be checked before application. The authorised initial baseline push precedes enforcement; future engineering should use reviewed PRs. No force push is used by M0-R1.

Verified 2026-11-11: GitHub branch protection API returned HTTP 404, Branch not protected. The recommendation has not been activated by this remediation.
