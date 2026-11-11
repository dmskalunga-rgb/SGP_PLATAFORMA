# M0-R1 tests

Fresh build, lint and typecheck passed. Unit tests: 2 PASS. Real PostgreSQL integration tests: 4 PASS. Real browser tests: 2 PASS. Migrations and app readiness use real PostgreSQL, including checksum rejection, rollback and unavailable dependencies. See EVIDENCE/M0-R1-TESTS.md and generated logs.

Container runtime tests, final image scans and remote CI are tracked separately and are not inferred from these local results. M0 acceptance remains blocked until all required evidence is complete.
