import test from 'node:test';
import assert from 'node:assert/strict';
import pg from 'pg';
import { mkdtemp, readFile, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { migrate } from '../../scripts/migrate.mjs';
import { withSchema } from '../helpers.mjs';
test('real PostgreSQL migration persists and repeat preserves its timestamp', async () => withSchema(async url => {
  await migrate(url); const db=new pg.Client({connectionString:url}); await db.connect();
  try { const before=await db.query('SELECT * FROM schema_migrations ORDER BY version'); await migrate(url); const after=await db.query('SELECT * FROM schema_migrations ORDER BY version'); assert.deepEqual(after.rows,before.rows); assert.deepEqual(after.rows.map(row=>row.version),['001','002','003','004']); }
  finally { await db.end(); }
}));
test('checksum drift is rejected and failed migration rolls back DDL and tracking rows', async () => withSchema(async url => {
  const dir=await mkdtemp(join(tmpdir(),'sgp-test-migrations-'));
  const original=await readFile(new URL('../../migrations/001_foundation.sql',import.meta.url),'utf8');
  const db=new pg.Client({connectionString:url}); await db.connect();
  try {
    await writeFile(join(dir,'001_foundation.sql'),original); await migrate(url,dir);
    await writeFile(join(dir,'001_foundation.sql'),original+'\n-- changed in TEST');
    await assert.rejects(migrate(url,dir),/checksum mismatch/);
    await writeFile(join(dir,'001_foundation.sql'),original);
    await writeFile(join(dir,'002_test_failure.sql'),'CREATE TABLE test_rollback(id integer); SELECT intentional_test_failure;');
    await assert.rejects(migrate(url,dir));
    assert.equal((await db.query("SELECT to_regclass('test_rollback') AS relation")).rows[0].relation,null);
    assert.equal((await db.query('SELECT count(*)::int AS count FROM schema_migrations')).rows[0].count,1);
  } finally { await db.end(); await rm(dir,{recursive:true,force:true}); }
}));
