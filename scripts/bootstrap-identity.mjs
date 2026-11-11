// One-time deployment command. Supply two real operator identities through protected stdin.
import pg from 'pg';
import { PasswordService } from '../apps/api/dist/password.js';
import { randomUUID } from 'node:crypto';
const url=process.env.BOOTSTRAP_DATABASE_URL;
if(!url)throw new Error('Explicit BOOTSTRAP_DATABASE_URL required; never a runtime connection');
let bootstrapUrl;
try{bootstrapUrl=new URL(url);}catch{throw new Error('Invalid protected bootstrap connection');}
if(process.env.NODE_ENV!=='test'&&bootstrapUrl.searchParams.get('sslmode')!=='verify-full')throw new Error('Verified PostgreSQL TLS required outside TEST');
let input='';
for await(const chunk of process.stdin) {input+=chunk.toString();if(Buffer.byteLength(input)>8192)throw new Error('Bootstrap input too large');}
let db;
try {
  const identities=JSON.parse(input);
  if(!Array.isArray(identities)||identities.length!==2)throw new Error('Two distinct operator identities required');
  const passwords=await PasswordService.create();
  const payload=[];
  for(const identity of identities) {
    if(!identity||Object.keys(identity).sort().join(',')!=='display_name,password,username'||typeof identity.username!=='string'||!/^[a-z0-9._-]{3,64}$/.test(identity.username)||typeof identity.display_name!=='string'||identity.display_name.length<1||identity.display_name.length>120||typeof identity.password!=='string')throw new Error('Invalid operator identity');
    payload.push({username:identity.username,display_name:identity.display_name,password_hash:await passwords.hash(identity.password)});
    identity.password=undefined;
  }
  input='';
  if(payload[0].username===payload[1].username)throw new Error('Distinct identities required');
  db=new pg.Client({connectionString:url});await db.connect();
  await db.query('SELECT iam.bootstrap($1,$2,$3,$4,$5)',[payload[0],payload[1],'127.0.0.1',randomUUID(),randomUUID()]);
  console.log('One-time identity bootstrap committed and audited. No credential or session is emitted.');
} catch {console.error('Bootstrap refused or failed; no partial identities committed. Inspect privately.');process.exitCode=1;}
finally {input='';if(db)await db.end();}
