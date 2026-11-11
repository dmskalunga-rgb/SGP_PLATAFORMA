import test,{before,after,beforeEach} from 'node:test';
import assert from 'node:assert/strict';
import pg from 'pg';
import { randomBytes,randomUUID } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import { migrate } from '../../scripts/migrate.mjs';
import { createApp } from '../../apps/api/dist/app.js';
import { PasswordService,baselinePasswordPolicy } from '../../apps/api/dist/password.js';
const origin='https://127.0.0.1:4175';
let owner,app,db,connection,people,bootstrap;
const actualLogs=[],seenTokens=[];
const fresh=()=>randomBytes(32).toString('base64url');
const headers={origin,'x-forwarded-proto':'https'};
const cookie=(reply)=>{const value=String(reply.headers['set-cookie']).split(';')[0];seenTokens.push(value.split('=')[1]);return value;};
async function request(method,url,payload,extra={}){return app.inject({method,url,headers:{...headers,...extra},payload});}
async function login(person,override={}){
 const pre=await request('GET','/api/v1/auth/csrf');assert.equal(pre.statusCode,200);
 return request('POST','/api/v1/auth/login',{username:person.username,password:person.password,...override},{cookie:cookie(pre),'x-csrf-token':pre.json().csrf_token});
}
async function current(c){return request('GET','/api/v1/auth/session',undefined,{cookie:c});}
async function mutation(c,path,payload){const s=await current(c);assert.equal(s.statusCode,200);return request('POST','/api/v1/auth/'+path,payload,{cookie:c,'x-csrf-token':s.json().csrf_token});}
before(async()=>{
 if(process.env.NODE_ENV!=='test')throw new Error('TEST only');
 connection=process.env.AUTH_DATABASE_URL?{owner:process.env.DATABASE_URL,runtime:process.env.APP_DATABASE_URL,auth:process.env.AUTH_DATABASE_URL}:JSON.parse(await readFile('.test-secrets/m1b-db.json','utf8'));
 assert.ok(connection.owner&&connection.runtime&&connection.auth);
 owner=new pg.Client({connectionString:connection.owner});await owner.connect();
 const database='test_auth_'+randomUUID().replaceAll('-','');await owner.query(`CREATE DATABASE ${database}`);
 const at=(url)=>{const u=new URL(url);u.pathname='/'+database;return u.href;};
 bootstrap={database,owner:at(connection.owner),runtime:at(connection.runtime),auth:at(connection.auth)};
 await migrate(bootstrap.owner);db=new pg.Client({connectionString:bootstrap.owner});await db.connect();
 const passwords=await PasswordService.create();people=[0,1,2].map(n=>({username:'test_'+n+'_'+randomUUID().replaceAll('-',''),display_name:'TEST ephemeral identity '+n,password:fresh()}));
 const identities=await Promise.all(people.slice(0,2).map(async p=>({username:p.username,display_name:p.display_name,password_hash:await passwords.hash(p.password)})));
 await db.query('SELECT iam.bootstrap($1,$2,$3,$4,$5)',[...identities,'127.0.0.1',randomUUID(),randomUUID()]);
 const third=await db.query("INSERT INTO iam.users(username,display_name,status) VALUES($1,$2,'ACTIVE') RETURNING id",[people[2].username,people[2].display_name]);
 await db.query('INSERT INTO iam.user_credentials(user_id,password_hash) VALUES($1,$2)',[third.rows[0].id,await passwords.hash(people[2].password)]);
 // Explicit metadata for this TEST-only identity; production never invents it.
 await db.query("INSERT INTO iam.user_security_attributes VALUES($1,'ACTIVE')",[third.rows[0].id]);
 await db.query("INSERT INTO iam.resource_security SELECT 'IAM_IDENTITY',$1,'IAM_GLOBAL',NULL,NULL,id,true,'PASSWORD' FROM iam.security_classifications ORDER BY rank LIMIT 1",[third.rows[0].id]);
 for(const p of people)p.id=(await db.query('SELECT id FROM iam.users WHERE username=$1',[p.username])).rows[0].id;
 app=await createApp({databaseUrl:bootstrap.runtime,host:'127.0.0.1',port:3100,logging:true,logStream:{write:message=>actualLogs.push(message)},trustedProxyIPs:['127.0.0.1'],auth:{databaseUrl:bootstrap.auth,origin,passwordPolicy:baselinePasswordPolicy,poolSize:1}});
 app.addHook('onSend',async(req)=>{if(req.auth){assert.ok(Object.isFrozen(req.auth));assert.ok(Object.isFrozen(req.auth.effective_grants));}});
});
beforeEach(async()=>{await db.query('TRUNCATE iam.rate_buckets,iam.preauth_nonces');await db.query("UPDATE iam.users SET status='ACTIVE',lock_kind=NULL,locked_until=NULL,failed_attempts=0,failure_window_start=NULL");});
after(async()=>{if(app)await app.close();if(db)await db.end();if(owner){if(bootstrap)await owner.query(`DROP DATABASE ${bootstrap.database} WITH(FORCE)`);await owner.end();}});

test('real login persists hash-only session, protected context, cookie flags; logout is idempotent and replay fails',async()=>{
 const result=await login(people[0]);assert.equal(result.statusCode,200,result.body);assert.equal(result.json().authenticated,true);
 const c=cookie(result),raw=c.split('=')[1];assert.match(raw,/^[\w-]{43}$/);assert.match(String(result.headers['set-cookie']),/HttpOnly; Secure; SameSite=Strict/);assert.ok(!String(result.headers['set-cookie']).includes('Domain='));
 const s=await current(c);assert.equal(s.statusCode,200,s.body);assert.equal(s.json().user.id,people[0].id);assert.ok(!s.body.includes(raw));assert.ok(!s.body.includes('password_hash'));
 const stored=(await db.query('SELECT token_hash FROM iam.sessions WHERE user_id=$1 ORDER BY created_at DESC LIMIT 1',[people[0].id])).rows[0];assert.equal(stored.token_hash.length,32);assert.notEqual(stored.token_hash.toString(),raw);
 const out=await mutation(c,'logout',{});assert.equal(out.statusCode,204,out.body);assert.equal((await current(c)).statusCode,401);
 const again=await request('POST','/api/v1/auth/logout',{},{cookie:c,'x-csrf-token':s.json().csrf_token});assert.equal(again.statusCode,204);
 assert.equal((await request('GET','/api/v1/auth/session',undefined,{cookie:'__Host-sgp_session='+fresh()})).statusCode,401);
});
test('wrong/unknown/disabled/locked have same public failure and malformed input/Origin/CSRF are rejected',async()=>{
 const wrong=await login(people[2],{password:fresh()});const unknown=await login({...people[2],username:'unknown_'+randomUUID().slice(0,8)});assert.equal(wrong.statusCode,401);assert.equal(unknown.statusCode,401);assert.equal(wrong.json().error,unknown.json().error);
 await db.query("UPDATE iam.users SET status='DISABLED' WHERE id=$1",[people[2].id]);const disabled=await login(people[2]);assert.equal(disabled.statusCode,401);
 await db.query("UPDATE iam.users SET status='LOCKED',lock_kind='MANUAL' WHERE id=$1",[people[2].id]);assert.equal((await login(people[2])).statusCode,401);
 await db.query("UPDATE iam.users SET status='ACTIVE',lock_kind=NULL,failed_attempts=0 WHERE id=$1",[people[2].id]);
 assert.equal((await request('POST','/api/v1/auth/login',{username:people[0].username,password:people[0].password,role:'admin'})).statusCode,400);
 assert.equal((await request('POST','/api/v1/auth/login',{username:'x'.repeat(65),password:'x'})).statusCode,400);
 assert.equal((await request('POST','/api/v1/auth/login',{username:people[0].username,password:'x'.repeat(129)})).statusCode,400);
 assert.equal((await request('POST','/api/v1/auth/login',{username:people[0].username,password:'x'},{origin:'https://hostile.invalid'})).statusCode,403);
 assert.equal((await request('POST','/api/v1/auth/login',{username:people[0].username,password:'x'})).statusCode,403);
});
test('five failures lock without extending lock, valid credential denied; authorized unlock then succeeds',async()=>{
 for(let i=0;i<5;i++)assert.equal((await login(people[2],{password:fresh()})).statusCode,401);
 const locked=(await db.query('SELECT status,locked_until FROM iam.users WHERE id=$1',[people[2].id])).rows[0];assert.equal(locked.status,'LOCKED');
 assert.equal((await login(people[2])).statusCode,401);assert.equal((await db.query('SELECT locked_until FROM iam.users WHERE id=$1',[people[2].id])).rows[0].locked_until.toISOString(),locked.locked_until.toISOString());
 const admin=await login(people[0]);assert.equal(admin.statusCode,200,admin.body);
 assert.equal((await mutation(cookie(admin),'admin/account-command',{target_id:people[2].id,action:'ACTIVE'})).statusCode,204);
 assert.equal((await login(people[2])).statusCode,200);
 const events=(await db.query('SELECT event FROM iam.authentication_events WHERE target_id=$1',[people[2].id])).rows.map(x=>x.event);assert.ok(events.includes('ACCOUNT_LOCKED')&&events.includes('ACCOUNT_UNLOCKED')&&events.includes('LOGIN_SUCCESS'));
});
test('absolute/idle expiry, revoke-one/all, concurrency, rotation and context reuse never accept an old session',async()=>{
 const a=await login(people[2]),b=await login(people[2]),admin=await login(people[0]);for(const r of[a,b,admin])assert.equal(r.statusCode,200,r.body);
 const ca=cookie(a),cb=cookie(b),co=cookie(admin);
 const sid=(await db.query('SELECT id FROM iam.sessions WHERE user_id=$1 AND revoked_at IS NULL ORDER BY created_at DESC LIMIT 1',[people[2].id])).rows[0].id;
 assert.equal((await mutation(co,'admin/account-command',{target_id:people[2].id,action:'REVOKE_ONE',session_id:sid})).statusCode,204);assert.equal((await current(cb)).statusCode,401);assert.equal((await current(ca)).statusCode,200);
 const old=await current(ca);const rotated=await request('POST','/api/v1/auth/rotate',{},{cookie:ca,'x-csrf-token':old.json().csrf_token});assert.equal(rotated.statusCode,200,rotated.body);assert.equal((await current(ca)).statusCode,401);assert.equal((await current(cookie(rotated))).statusCode,200);
 assert.equal((await mutation(co,'admin/account-command',{target_id:people[2].id,action:'REVOKE_ALL'})).statusCode,204);assert.equal((await current(cookie(rotated))).statusCode,401);
 const expired=await login(people[2]);assert.equal(expired.statusCode,200);await db.query("UPDATE iam.sessions SET idle_expires_at=clock_timestamp()-interval '1 second' WHERE token_hash=iam_crypto.digest($1,'sha256')",[cookie(expired).split('=')[1]]);assert.equal((await current(cookie(expired))).statusCode,401);
 for(const person of people.slice(0,2)){const l=await login(person);assert.equal(l.statusCode,200);assert.equal((await current(cookie(l))).json().user.id,person.id);}
});
test('internal FORCE RLS and runtime privilege boundaries; poisoned GUC, closed bind, rollback and SQL denial',async()=>{
 const result=await login(people[0]);const raw=cookie(result).split('=')[1];const runtime=new pg.Client({connectionString:bootstrap.runtime});await runtime.connect();
 try{
 const flags=(await runtime.query('SELECT rolsuper,rolcreaterole,rolcreatedb,rolbypassrls FROM pg_roles WHERE rolname=current_user')).rows[0];assert.ok(Object.values(flags).every(v=>!v));
 for(const sql of ['SELECT * FROM iam.user_credentials',"UPDATE iam.users SET status='ACTIVE'",'DELETE FROM iam.authentication_events',"SELECT iam.credential_lookup('unknown')","SET ROLE sgp_context_owner"]){await assert.rejects(runtime.query(sql));}
 await runtime.query("SET app.user_id='forged'; SET app.session_id='forged'");assert.equal((await runtime.query('SELECT iam.bound_context() AS ctx')).rows[0].ctx,null);
 await runtime.query('BEGIN');await runtime.query('SELECT iam.bind_request($1,false,$2,$3,$4)',[raw,'127.0.0.1',randomUUID(),randomUUID()]);const ctx=(await runtime.query('SELECT iam.bound_context() AS ctx')).rows[0].ctx;assert.equal(ctx.user_id,people[0].id);
 await runtime.query('SELECT iam.finish_request()');assert.equal((await runtime.query('SELECT iam.bound_context() AS ctx')).rows[0].ctx,null);await assert.rejects(runtime.query('SELECT iam.bind_request($1,false,$2,$3,$4)',[raw,'127.0.0.1',randomUUID(),randomUUID()]));await runtime.query('ROLLBACK');assert.equal((await runtime.query('SELECT iam.bound_context() AS ctx')).rows[0].ctx,null);
 const rls=(await db.query("SELECT relrowsecurity,relforcerowsecurity FROM pg_class WHERE oid='iam.sessions'::regclass")).rows[0];assert.ok(rls.relrowsecurity&&rls.relforcerowsecurity);
 } finally{await runtime.end();}
});
test('audit failure rolls back session creation; bootstrap refuses second execution and runtimes cannot invoke it',async()=>{
 const count=Number((await db.query('SELECT count(*) FROM iam.sessions')).rows[0].count);
 await db.query('REVOKE INSERT ON iam.authentication_events FROM sgp_audit_writer');
 try{const result=await login(people[0]);assert.equal(result.statusCode,503,result.body);assert.ok(!result.body.includes('password')&&!result.body.includes('query'));assert.equal(Number((await db.query('SELECT count(*) FROM iam.sessions')).rows[0].count),count);}finally{await db.query('GRANT INSERT ON iam.authentication_events TO sgp_audit_writer');}
 await assert.rejects(db.query('SELECT iam.bootstrap($1,$2,$3,$4,$5)',[{},{} ,'127.0.0.1',randomUUID(),randomUUID()]));
 const auth=new pg.Client({connectionString:bootstrap.auth});await auth.connect();try{await assert.rejects(auth.query('SELECT iam.bootstrap($1,$2,$3,$4,$5)',[{},{},'127.0.0.1',randomUUID(),randomUUID()]));await assert.rejects(auth.query('SELECT * FROM iam.authentication_events'));}finally{await auth.end();}
});
test('password change revokes every session and only the new password verifies',async()=>{
 const a=await login(people[2]),b=await login(people[2]);const freshPassword=fresh();
 assert.equal((await mutation(cookie(a),'change-password',{current_password:people[2].password,new_password:freshPassword})).statusCode,204);
 assert.equal((await current(cookie(a))).statusCode,401);assert.equal((await current(cookie(b))).statusCode,401);
 assert.equal((await login(people[2])).statusCode,401);people[2].password=freshPassword;assert.equal((await login(people[2])).statusCode,200);
});
test('IP rate budget is enforced before hashing and preauth nonce cannot be replayed',async()=>{
 const pre=await request('GET','/api/v1/auth/csrf');const proof={cookie:cookie(pre),'x-csrf-token':pre.json().csrf_token};
 const input={username:'unknown_rate',password:fresh()};assert.equal((await request('POST','/api/v1/auth/login',input,proof)).statusCode,401);assert.equal((await request('POST','/api/v1/auth/login',input,proof)).statusCode,403);
 for(let i=0;i<9;i++)assert.equal((await login({...people[2],username:'unknown_rate'})).statusCode,401);
 assert.equal((await login(people[2])).statusCode,429);
});
test('account lifecycle commands require explicit authority, deny self-target and protect last operators',async()=>{
 const admin=await login(people[0]),user=await login(people[2]);const a=cookie(admin),u=cookie(user);
 assert.equal((await mutation(u,'admin/account-command',{target_id:people[1].id,action:'REVOKE_ALL'})).statusCode,403);
 assert.equal((await mutation(a,'admin/account-command',{target_id:people[0].id,action:'DISABLED'})).statusCode,403);
 assert.equal((await mutation(a,'admin/account-command',{target_id:people[1].id,action:'DISABLED'})).statusCode,403);
 for(const action of ['INACTIVE','LOCKED','DISABLED']) {
  assert.equal((await mutation(a,'admin/account-command',{target_id:people[2].id,action})).statusCode,204);
  assert.equal((await login(people[2])).statusCode,401);
  assert.equal((await mutation(a,'admin/account-command',{target_id:people[2].id,action:'ACTIVE'})).statusCode,204);
  assert.equal((await login(people[2])).statusCode,200);
 }
});
test('absolute expiry and concurrent API identity contexts remain isolated',async()=>{
 const a=await login(people[0]),b=await login(people[1]);
 const [sa,sb]=await Promise.all([current(cookie(a)),current(cookie(b))]);assert.equal(sa.json().user.id,people[0].id);assert.equal(sb.json().user.id,people[1].id);assert.ok(!sa.body.includes(people[1].id)&&!sb.body.includes(people[0].id));
 const c=await login(people[2]);const raw=cookie(c).split('=')[1];
 await db.query("UPDATE iam.sessions SET created_at=clock_timestamp()-interval '9 hours',expires_at=clock_timestamp()-interval '1 minute',idle_expires_at=clock_timestamp()-interval '2 minutes' WHERE token_hash=iam_crypto.digest($1,'sha256')",[raw]);assert.equal((await current(cookie(c))).statusCode,401);
});
test('revocation commit linearizes after an authorized transaction and invalidates every subsequent binding',async()=>{
 const user=await login(people[2]),admin=await login(people[0]);const c=cookie(user),a=cookie(admin),adminSession=(await current(a)).json();
 const client=new pg.Client({connectionString:bootstrap.runtime});await client.connect();
 try{
 await client.query('BEGIN');await client.query('SELECT iam.bind_request($1,false,$2,$3,$4)',[c.split('=')[1],'127.0.0.1',randomUUID(),randomUUID()]);
 const revocation=request('POST','/api/v1/auth/admin/account-command',{target_id:people[2].id,action:'REVOKE_ALL'},{cookie:a,'x-csrf-token':adminSession.csrf_token});
 let waiting=false;
 for(let i=0;i<50&&!waiting;i++){waiting=(await db.query("SELECT EXISTS(SELECT FROM pg_stat_activity WHERE datname=current_database() AND usename='app_runtime' AND wait_event_type='Lock') AS waiting")).rows[0].waiting;if(!waiting)await new Promise(r=>setTimeout(r,20));}
 assert.ok(waiting,'revocation must wait for prior transaction');await client.query('SELECT iam.finish_request()');await client.query('COMMIT');assert.equal((await revocation).statusCode,204);assert.equal((await current(c)).statusCode,401);
 }finally{await client.end();}
});
test('PostgreSQL total transaction deadline releases locks even across many short statements',async()=>{
 const loginResult=await login(people[0]),raw=cookie(loginResult).split('=')[1];const client=new pg.Client({connectionString:bootstrap.runtime});client.on('error',()=>{});await client.connect();let timedOut=false;
 try{
 assert.equal((await client.query("SELECT current_setting('transaction_timeout') AS value")).rows[0].value,'15s');
 await client.query('BEGIN');await client.query('SELECT iam.bind_request($1,false,$2,$3,$4)',[raw,'127.0.0.1',randomUUID(),randomUUID()]);
 const pid=(await client.query('SELECT pg_backend_pid() AS pid')).rows[0].pid;
 try{for(let i=0;i<100;i++)await client.query('SELECT pg_sleep(0.2)');}catch{timedOut=true;}
 assert.ok(timedOut);assert.equal((await db.query('SELECT count(*)::int AS n FROM pg_stat_activity WHERE pid=$1',[pid])).rows[0].n,0);
 }finally{await client.end().catch(()=>{});}
});
test('real serialized application logs and API bodies do not disclose credential material or session cookies',async()=>{
 const result=await login(people[0]);assert.equal(result.statusCode,200);const c=cookie(result);const session=await current(c);assert.equal(session.statusCode,200);
 await login(people[0],{password:fresh()});const serialized=actualLogs.join('\n');assert.ok(serialized.includes('authentication_request_failed'));
 for(const p of people)assert.ok(!serialized.includes(p.password));for(const raw of seenTokens.filter(Boolean))assert.ok(!serialized.includes(raw));
 const hashes=(await db.query('SELECT password_hash FROM iam.user_credentials')).rows.map(r=>r.password_hash);for(const hash of hashes)assert.ok(!serialized.includes(hash)&&!session.body.includes(hash));
});
