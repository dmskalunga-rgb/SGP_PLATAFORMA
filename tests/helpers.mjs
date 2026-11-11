import pg from 'pg';
import { randomUUID } from 'node:crypto';
export async function withSchema(run) {
  if (!process.env.DATABASE_URL || process.env.NODE_ENV !== 'test') throw new Error('Use an isolated TEST PostgreSQL and NODE_ENV=test');
  const root = new pg.Client({ connectionString: process.env.DATABASE_URL });
  await root.connect();
  const schema = 'test_' + randomUUID().replaceAll('-', '');
  const scoped = new URL(process.env.DATABASE_URL);
  scoped.pathname='/' + schema;
  scoped.searchParams.delete('options');
  try { await root.query(`CREATE DATABASE ${schema}`); await run(scoped.href); }
  finally { await root.query(`DROP DATABASE IF EXISTS ${schema} WITH (FORCE)`); await root.end(); }
}
