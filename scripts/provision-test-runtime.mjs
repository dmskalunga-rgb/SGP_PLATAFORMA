// TEST/CI only: creates an ephemeral, least-privilege PostgreSQL runtime role.
import pg from 'pg';
if(process.env.NODE_ENV!=='test'||!process.env.RUNTIME_PASSWORD)throw new Error('TEST environment and ephemeral runtime password required');
const db=new pg.Client({connectionString:process.env.DATABASE_URL});await db.connect();
try {
  const statement=await db.query("SELECT format('CREATE ROLE sgp_runtime LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS PASSWORD %L', $1::text) AS sql",[process.env.RUNTIME_PASSWORD]);
  await db.query(statement.rows[0].sql);
  await db.query('GRANT CONNECT ON DATABASE sgp_test TO sgp_runtime');
  await db.query('GRANT USAGE ON SCHEMA public TO sgp_runtime');
  await db.query('GRANT SELECT ON schema_migrations TO sgp_runtime');
  console.log('Disposable TEST runtime role provisioned without elevated privileges');
} finally {await db.end();}
