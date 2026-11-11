# Contribution and change control

The frozen master is authoritative. Each implementation task requires the canonical DoR and each claimed completion needs DoD, tests and evidence. Keep M1 blocked until the M0 gate passes and explicit separate authorisation is issued. Do not alter the master without a formal CR.

Run the local and remote mandatory gates; never bypass failing checks or replace PostgreSQL integrations with mocks. Use ephemeral TEST data only and exclude secrets, temporary files and dependency trees from commits. Code changes use ADRs where appropriate. Review source, dependency and image reports before promotion. See docs/operations/BRANCH-PROTECTION.md for the proposed repository policy.
