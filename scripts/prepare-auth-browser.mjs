import pg from 'pg';
import { randomBytes,randomUUID } from 'node:crypto';
import { writeFile,mkdir } from 'node:fs/promises';
import { spawn } from 'node:child_process';
import { migrate } from './migrate.mjs';
if(process.env.NODE_ENV!=='test'||!process.env.DATABASE_URL||!process.env.APP_DATABASE_URL||!process.env.AUTH_DATABASE_URL)throw new Error('TEST database connections required');
await mkdir('.test-secrets',{recursive:true});
const database='test_browser_'+randomUUID().replaceAll('-','');
const at=url=>{const u=new URL(url);u.pathname='/'+database;return u.href;};
const connections={owner:at(process.env.DATABASE_URL),runtime:at(process.env.APP_DATABASE_URL),auth:at(process.env.AUTH_DATABASE_URL)};
const root=new pg.Client({connectionString:process.env.DATABASE_URL});await root.connect();
try{await root.query(`CREATE DATABASE ${database}`);}finally{await root.end();}
const people=[0,1].map(n=>({username:'test_browser_'+n+'_'+randomUUID().slice(0,8),display_name:'TEST browser operator '+n,password:randomBytes(24).toString('base64url')}));
await writeFile('.test-secrets/auth-browser.json',JSON.stringify({database,connections,people}));
await migrate(connections.owner);
const child=spawn(process.execPath,['scripts/bootstrap-identity.mjs'],{env:{...process.env,BOOTSTRAP_DATABASE_URL:connections.owner},stdio:['pipe','pipe','pipe']});
child.stdin.end(JSON.stringify(people));
child.stdout.resume();child.stderr.resume();
const code=await new Promise((resolve,reject)=>{child.on('error',reject);child.on('close',resolve);});
if(code!==0)throw new Error('Real TEST bootstrap command failed');
const db=new pg.Client({connectionString:connections.owner});await db.connect();
try{for(const person of people)person.id=(await db.query('SELECT id FROM iam.users WHERE username=$1',[person.username])).rows[0].id;}finally{await db.end();}
await writeFile('.test-secrets/auth-browser.json',JSON.stringify({database,connections,people}));
console.log('Disposable browser identities bootstrapped with the real one-time command');
