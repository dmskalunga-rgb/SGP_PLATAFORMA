# PostgreSQL and migrations

PostgreSQL is the source of truth. The only M0 table is schema_migrations(version primary key, checksum not null, applied_at not null). There are no operational entities, seed datasets or sensitive tables requiring an M1 RLS model at this stage.

Set DATABASE_URL externally and execute `npm run migrate`. Use a dedicated migration owner, not the application runtime identity. The runner locks concurrent migration execution, sorts versioned filenames, checks checksums before re-executing anything, rejects duplicate versions and unknown applied versions, and commits all changes atomically. Never edit an applied migration; append a new migration under formal change control. The tests execute checksum rejection, repeat/idempotency and deliberate DDL failure/rollback directly against real PostgreSQL in unique TEST schemas.

Runtime provisioning: the DBA creates a separate LOGIN with NOSUPERUSER, NOCREATEDB, NOCREATEROLE and NOBYPASSRLS; grant database CONNECT, schema USAGE and SELECT on schema_migrations only. Credentials never belong in SQL under version control. scripts/provision-test-runtime.mjs does this solely for disposable TEST databases; it is not a production provisioning procedure. Database roles are infrastructure identities, not the M1 application role/permission model.

The Compose baseline retains a persistent named volume. Deleting it is not a rollback. Before any future production schema change, require a verified backup, compatibility review, migration evidence and a reviewed rollback/recovery decision.
