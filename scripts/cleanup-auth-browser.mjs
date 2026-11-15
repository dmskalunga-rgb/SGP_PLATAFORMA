import { readFile,unlink } from 'node:fs/promises';
import pg from 'pg';
export default async function cleanup(){
 if(process.env.NODE_ENV!=='test')throw new Error('TEST only');
 const fixture=JSON.parse(await readFile('.test-secrets/auth-browser.json','utf8'));
 if(!/^test_browser_[a-f0-9]{32}$/.test(fixture.database))throw new Error('Invalid isolated database');
 const response=await fetch('http://127.0.0.1:3101/__test_shutdown',{method:'POST',headers:{'X-Test-Shutdown':fixture.shutdown_token}});
 if(response.status!==202)throw new Error('TEST server shutdown denied');
 let stopped=false;
 for(let attempt=0;attempt<50;attempt++){
  try{await fetch('http://127.0.0.1:3101/health/live');}catch{stopped=true;break;}
  await new Promise(resolve=>setTimeout(resolve,100));
 }
 if(!stopped)throw new Error('TEST API pools did not close before database teardown');
 const connection=new URL(fixture.connections.owner);connection.pathname='/postgres';
 const db=new pg.Client({connectionString:connection.href});await db.connect();
 try{await db.query(`DROP DATABASE IF EXISTS ${fixture.database} WITH(FORCE)`);}finally{await db.end();}
 await unlink('.test-secrets/auth-browser.json');
}
