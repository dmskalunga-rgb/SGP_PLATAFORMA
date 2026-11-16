import { readFile,unlink,writeFile } from 'node:fs/promises';
import pg from 'pg';
export default async function cleanup(){
 if(process.env.NODE_ENV!=='test')throw new Error('TEST only');
 const fixture=JSON.parse(await readFile('.test-secrets/auth-browser.json','utf8'));
 if(!/^test_browser_[a-f0-9]{32}$/.test(fixture.database))throw new Error('Invalid isolated database');
 const response=await fetch('http://127.0.0.1:3101/__test_shutdown',{method:'POST',headers:{'X-Test-Shutdown':fixture.shutdown_token}});
 if(response.status!==202)throw new Error('TEST server shutdown denied');
 let stopped=false;
 for(let attempt=0;attempt<50;attempt++){
  // Listener shutdown precedes onClose hooks/pool draining. Only a nonce-bound
  // acknowledgement written after app.close() proves every pool has closed.
  try{const ack=JSON.parse(await readFile('.test-secrets/auth-browser-closed.json','utf8'));if(ack.database===fixture.database&&ack.shutdown_token===fixture.shutdown_token){stopped=true;break;}}catch{ /* not yet acknowledged */ }
  await new Promise(resolve=>setTimeout(resolve,100));
 }
 if(!stopped)throw new Error('TEST API pools did not close before database teardown');
 const connection=new URL(fixture.connections.owner);connection.pathname='/postgres';
 const db=new pg.Client({connectionString:connection.href});await db.connect();
 try{
  const connections=(await db.query('SELECT count(*)::int AS n FROM pg_stat_activity WHERE datname=$1',[fixture.database])).rows[0].n;
  if(connections!==0)throw new Error('TEST database still has connections after pool-close acknowledgement');
  await db.query(`DROP DATABASE ${fixture.database}`);
  const remains=(await db.query('SELECT count(*)::int AS n FROM pg_database WHERE datname=$1',[fixture.database])).rows[0].n;
  if(remains!==0)throw new Error('TEST database cleanup incomplete');
  await writeFile('artifacts/auth-browser-lifecycle.json',JSON.stringify({database:fixture.database,app_close_acknowledged:true,connections_before_drop:connections,drop_without_force:true,database_absent:true},null,2));
 }finally{await db.end();}
 await unlink('.test-secrets/auth-browser.json');
 await unlink('.test-secrets/auth-browser-closed.json');
}
