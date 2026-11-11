import pg from 'pg';
if(process.env.NODE_ENV!=='test'||!process.env.AUTH_DATABASE_URL||!process.env.APP_DATABASE_URL||!process.env.DATABASE_URL)throw new Error('Isolated TEST credentials required');
const db=new pg.Client({connectionString:process.env.DATABASE_URL});await db.connect();
try {
  for(const [role,url] of [['app_runtime',process.env.APP_DATABASE_URL],['auth_runtime',process.env.AUTH_DATABASE_URL]]) {
    const parsed=new URL(url);if(parsed.username!==role)throw new Error('Wrong TEST role');
    const result=await db.query("SELECT format('ALTER ROLE %I LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS PASSWORD %L', $1::text,$2::text) AS sql",[role,decodeURIComponent(parsed.password)]);
    await db.query(result.rows[0].sql);
  }
  console.log('Separate least-privilege TEST app/auth identities provisioned');
} finally {await db.end();}
