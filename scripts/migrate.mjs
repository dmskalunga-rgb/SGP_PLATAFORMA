import pg from 'pg';
import { readFile, readdir } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { join } from 'node:path';

export async function migrate(connectionString, directory = fileURLToPath(new URL('../migrations', import.meta.url))) {
  if (!connectionString) throw new Error('DATABASE_URL required');
  const client = new pg.Client({ connectionString, connectionTimeoutMillis: 5000 });
  await client.connect();
  try {
    await client.query('BEGIN');
    await client.query("SELECT pg_advisory_xact_lock(hashtext('sgp_migrations'))");
    await client.query('CREATE TABLE IF NOT EXISTS schema_migrations (version text PRIMARY KEY, checksum text NOT NULL, applied_at timestamptz NOT NULL DEFAULT now())');
    const files = (await readdir(directory)).filter(name => /^\d{3}_[a-z_]+\.sql$/.test(name)).sort();
    if (!files.length) throw new Error('No migrations found');
    const versions = new Set();
    for (const name of files) {
      const version = name.split('_')[0];
      if (versions.has(version)) throw new Error('Duplicate migration version');
      versions.add(version);
      const sql = await readFile(join(directory, name), 'utf8');
      const checksum = createHash('sha256').update(sql).digest('hex');
      const old = await client.query('SELECT checksum FROM schema_migrations WHERE version=$1', [version]);
      if (old.rowCount) {
        if (old.rows[0].checksum !== checksum) throw new Error('Migration checksum mismatch');
      } else {
        await client.query(sql);
        await client.query('INSERT INTO schema_migrations(version,checksum) VALUES ($1,$2)', [version, checksum]);
      }
    }
    const applied = await client.query('SELECT version FROM schema_migrations');
    if (applied.rows.some(row => !versions.has(row.version))) throw new Error('Database version is ahead of this release');
    await client.query('COMMIT');
    return [...versions];
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally { await client.end(); }
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try { console.log('Migrations validated:', (await migrate(process.env.DATABASE_URL)).join(', ')); }
  catch { console.error('Migration failed; transaction rolled back. Inspect the database privately.'); process.exitCode = 1; }
}
