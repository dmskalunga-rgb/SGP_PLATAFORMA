import { readFile,unlink } from 'node:fs/promises';
import pg from 'pg';
export default async function cleanup(){
 if(process.env.NODE_ENV!=='test')throw new Error('TEST only');
 const fixture=JSON.parse(await readFile('.test-secrets/auth-browser.json','utf8'));
 if(!/^test_browser_[a-f0-9]{32}$/.test(fixture.database))throw new Error('Invalid isolated database');
 const connection=new URL(fixture.connections.owner);connection.pathname='/postgres';
 const db=new pg.Client({connectionString:connection.href});await db.connect();
 try{await db.query(`DROP DATABASE IF EXISTS ${fixture.database} WITH(FORCE)`);}finally{await db.end();}
 await unlink('.test-secrets/auth-browser.json');
}
