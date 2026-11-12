import test,{before,after} from 'node:test';
import assert from 'node:assert/strict';
import pg from 'pg';
import {randomBytes,randomUUID} from 'node:crypto';
import {migrate} from '../../scripts/migrate.mjs';
import {createApp} from '../../apps/api/dist/app.js';
import {PasswordService,baselinePasswordPolicy} from '../../apps/api/dist/password.js';
import {csrfFor} from '../../apps/api/dist/auth.js';

const fresh=()=>randomBytes(32).toString('base64url');
const origin='https://127.0.0.1:4175',meta=()=>['127.0.0.1',randomUUID(),randomUUID()];
let root,db,app,pool,urls,database,users,classes,scopes,compartments,role,permission,resources;
const time=new Date(Date.now()-60000).toISOString();
async function login(person){
 const pre=await app.inject({url:'/api/v1/auth/csrf',headers:{'x-forwarded-proto':'https'}});
 assert.equal(pre.statusCode,200,pre.body);
 const response=await app.inject({method:'POST',url:'/api/v1/auth/login',headers:{origin,'x-forwarded-proto':'https',cookie:String(pre.headers['set-cookie']).split(';')[0],'x-csrf-token':pre.json().csrf_token},payload:{username:person.username,password:person.password}});
 assert.equal(response.statusCode,200,response.body);return String(response.headers['set-cookie']).split(';')[0].split('=')[1];
}
async function api(raw,path,payload){return app.inject({method:payload===undefined?'GET':'POST',url:'/api/v1/security/'+path,headers:{origin,'x-forwarded-proto':'https',cookie:'__Host-sgp_session='+raw,'x-csrf-token':csrfFor(raw)},payload});}
async function tx(raw,run,write=false){const c=await pool.connect();try{await c.query('BEGIN');const ctx=(await c.query('SELECT iam.bind_request($1,$2,$3,$4,$5) AS ctx',[raw,write,...meta()])).rows[0].ctx;const result=await run(c,ctx);await c.query('SELECT iam.finish_request()');await c.query('COMMIT');return result;}catch(e){await c.query('ROLLBACK');throw e;}finally{c.release();}}
async function command(person,path,payload){return api(person.token,path,payload);}
async function matrix(raw,id,expected,label){
 const sql=await tx(raw,async(c,ctx)=>{
  const d=(await c.query('SELECT iam.authorize($1,$2,$3,$4,$5) AS d',[ctx.user_id,'security.roles.read','IAM_ROLE',id,ctx])).rows[0].d;
  const rows=(await c.query('SELECT id FROM iam.roles WHERE id=$1',[id])).rows;
  assert.equal(d.decision,expected?'ALLOW':'DENY',label+' decision');assert.equal(rows.length,expected?1:0,label+' RLS');return d;
 });
 const http=await api(raw,'roles/'+id);assert.equal(http.statusCode,expected?200:404,label+' API '+http.body);return sql;
}
before(async()=>{
 assert.equal(process.env.NODE_ENV,'test');assert.ok(process.env.DATABASE_URL&&process.env.APP_DATABASE_URL&&process.env.AUTH_DATABASE_URL);
 root=new pg.Client({connectionString:process.env.DATABASE_URL});await root.connect();database='test_m1c_'+randomUUID().replaceAll('-','');await root.query(`CREATE DATABASE ${database}`);
 const at=url=>{const u=new URL(url);u.pathname='/'+database;return u.href;};urls={owner:at(process.env.DATABASE_URL),app:at(process.env.APP_DATABASE_URL),auth:at(process.env.AUTH_DATABASE_URL)};
 await migrate(urls.owner);db=new pg.Client({connectionString:urls.owner});await db.connect();pool=new pg.Pool({connectionString:urls.app,max:1});
 const passwords=await PasswordService.create();users=Array.from({length:5},(_,n)=>({username:'test_m1c_'+n+'_'+randomUUID().slice(0,8),display_name:'TEST ephemeral operator '+n,password:fresh()}));
 const founders=await Promise.all(users.slice(0,2).map(async u=>({username:u.username,display_name:u.display_name,password_hash:await passwords.hash(u.password)})));
 await db.query('SELECT iam.bootstrap($1,$2,$3,$4,$5)',[...founders,...meta()]);
 classes=(await db.query('SELECT * FROM iam.security_classifications ORDER BY rank')).rows;
 for(const u of users.slice(2)){u.id=(await db.query("INSERT INTO iam.users(username,display_name,status) VALUES($1,$2,'ACTIVE') RETURNING id",[u.username,u.display_name])).rows[0].id;await db.query('INSERT INTO iam.user_credentials(user_id,password_hash) VALUES($1,$2)',[u.id,await passwords.hash(u.password)]);await db.query("INSERT INTO iam.user_security_attributes VALUES($1,'ACTIVE')",[u.id]);}
 // TEST-only provisioning supplies institutional decisions rather than production defaults.
 for(const u of users.slice(0,2))u.id=(await db.query('SELECT id FROM iam.users WHERE username=$1',[u.username])).rows[0].id;
 scopes=(await db.query('INSERT INTO iam.security_scope_refs DEFAULT VALUES RETURNING id')).rows.map(r=>r.id);scopes.push((await db.query('INSERT INTO iam.security_scope_refs DEFAULT VALUES RETURNING id')).rows[0].id);
 for(const u of users.slice(2)){await db.query("INSERT INTO iam.resource_security VALUES('IAM_IDENTITY',$1,'SCOPED',$2,NULL,$3,true,'PASSWORD')",[u.id,scopes[0],classes[0].id]);await db.query('INSERT INTO iam.security_clearances VALUES($1,$2,$3,NULL,$4)',[u.id,classes[1].id,time,users[0].id]);}
 compartments=[];for(let n=0;n<2;n++)compartments.push((await db.query('INSERT INTO iam.security_compartments(code,sensitive) VALUES($1,false) RETURNING id',['TEST_'+n+'_'+randomUUID().slice(0,8)])).rows[0].id);
 // Operators receive explicit TEST scoped delegation/clearance; holding permissions alone is insufficient.
 for(const u of users.slice(0,2)){
  await db.query('INSERT INTO iam.security_clearances VALUES($1,$2,$3,NULL,$1)',[u.id,classes[4].id,time]);
  await db.query('UPDATE iam.delegation_authority SET ceiling_rank=4 WHERE user_id=$1',[u.id]);
  await db.query("INSERT INTO iam.delegation_authority SELECT $1,id,'SCOPED',$2,4,$3,NULL FROM iam.permissions",[u.id,scopes[0],time]);
  const adminRole=(await db.query("SELECT id FROM iam.roles WHERE code='SECURITY_BOOTSTRAP_OPERATOR'")).rows[0].id;
  await db.query("INSERT INTO iam.user_roles(user_id,role_id,scope_kind,scope_id,valid_from) VALUES($1,$2,'SCOPED',$3,$4)",[u.id,adminRole,scopes[0],time]);await db.query('INSERT INTO iam.user_scope_bindings VALUES($1,$2,$3,NULL)',[u.id,scopes[0],time]);
  for(const comp of compartments)await db.query('INSERT INTO iam.user_compartments VALUES($1,$2,$3,NULL,$1)',[u.id,comp,time]);
 }
 permission=(await db.query("SELECT id FROM iam.permissions WHERE code='security.roles.read'")).rows[0].id;
 role=(await db.query("INSERT INTO iam.roles(code) VALUES('TEST_READER') RETURNING id")).rows[0].id;await db.query('INSERT INTO iam.role_permissions VALUES($1,$2)',[role,permission]);
 for(const u of users.slice(2)){await db.query("INSERT INTO iam.user_roles(user_id,role_id,scope_kind,scope_id,valid_from) VALUES($1,$2,'SCOPED',$3,$4)",[u.id,role,scopes[0],time]);await db.query('INSERT INTO iam.user_scope_bindings VALUES($1,$2,$3,NULL)',[u.id,scopes[0],time]);}
 await db.query('INSERT INTO iam.user_compartments VALUES($1,$2,$3,NULL,$4)',[users[2].id,compartments[0],time,users[0].id]);
 resources=[];
 for(const [n,scope,level,comps,complete] of [[0,scopes[0],0,[],true],[1,scopes[1],0,[],true],[2,scopes[0],4,[],true],[3,scopes[0],0,compartments,true],[4,scopes[0],0,[],false]]){
  const id=(await db.query('INSERT INTO iam.roles(code) VALUES($1) RETURNING id',['TEST_RESOURCE_'+n])).rows[0].id;resources.push(id);
  await db.query("INSERT INTO iam.resource_security VALUES('IAM_ROLE',$1,'SCOPED',$2,NULL,$3,$4,'PASSWORD')",[id,scope,classes[level].id,complete]);for(const comp of comps)await db.query("INSERT INTO iam.resource_compartments VALUES('IAM_ROLE',$1,$2)",[id,comp]);
 }
 app=await createApp({databaseUrl:urls.app,host:'127.0.0.1',port:3100,logging:false,trustedProxyIPs:['127.0.0.1'],auth:{databaseUrl:urls.auth,origin,passwordPolicy:baselinePasswordPolicy,poolSize:1}});
 for(const u of users)u.token=await login(u);
});
after(async()=>{if(app)await app.close();if(pool)await pool.end();if(db)await db.end();if(root){if(database)await root.query(`DROP DATABASE ${database} WITH(FORCE)`);await root.end();}});

test('M1C matrix: same scope, cross scope, rank, all compartments and explicit metadata agree in API and RLS',async()=>{
 await matrix(users[2].token,resources[0],true,'same scope');await matrix(users[2].token,resources[1],false,'cross scope');await matrix(users[2].token,resources[2],false,'classification');await matrix(users[2].token,resources[3],false,'partial compartment');await matrix(users[2].token,resources[4],false,'missing metadata');
 await db.query('INSERT INTO iam.user_compartments VALUES($1,$2,$3,NULL,$4)',[users[2].id,compartments[1],time,users[0].id]);await matrix(users[2].token,resources[3],true,'complete compartments');
 await db.query('UPDATE iam.security_clearances SET valid_to=clock_timestamp()-interval \'1 second\' WHERE user_id=$1',[users[2].id]);await matrix(users[2].token,resources[0],false,'expired clearance');await db.query('DELETE FROM iam.security_clearances WHERE user_id=$1',[users[2].id]);await matrix(users[2].token,resources[0],false,'absent clearance');await db.query('INSERT INTO iam.security_clearances VALUES($1,$2,$3,NULL,$4)',[users[2].id,classes[1].id,time,users[0].id]);
});
test('M1C effective grant never combines permission from A with scope/location of B; inactive, future and expired deny',async()=>{
 const other=(await db.query("INSERT INTO iam.roles(code) VALUES('TEST_OTHER_SCOPE') RETURNING id")).rows[0].id;const p=(await db.query("SELECT id FROM iam.permissions WHERE code='security.users.read'")).rows[0].id;await db.query('INSERT INTO iam.role_permissions VALUES($1,$2)',[other,p]);await db.query("INSERT INTO iam.user_roles(user_id,role_id,scope_kind,scope_id,valid_from) VALUES($1,$2,'SCOPED',$3,$4)",[users[2].id,other,scopes[1],time]);await db.query('INSERT INTO iam.user_scope_bindings VALUES($1,$2,$3,NULL)',[users[2].id,scopes[1],time]);
 await matrix(users[2].token,resources[1],false,'no Cartesian scope');
 const g=await tx(users[2].token,async(_c,ctx)=>ctx.effective_grants);assert.ok(g.every(v=>v.permission_id&&v.assignment_id&&Array.isArray(v.scope_set)&&Array.isArray(v.location_set)&&v.valid_from));
 await db.query("UPDATE iam.roles SET status='INACTIVE' WHERE id=$1",[role]);await matrix(users[2].token,resources[0],false,'inactive role');await db.query("UPDATE iam.roles SET status='ACTIVE' WHERE id=$1",[role]);
 await db.query('UPDATE iam.user_roles SET valid_to=clock_timestamp()-interval \'1 second\' WHERE user_id=$1 AND role_id=$2',[users[2].id,role]);await matrix(users[2].token,resources[0],false,'expired grant');await db.query('UPDATE iam.user_roles SET valid_to=NULL,valid_from=clock_timestamp()+interval \'1 day\' WHERE user_id=$1 AND role_id=$2',[users[2].id,role]);await matrix(users[2].token,resources[0],false,'future grant');await db.query('UPDATE iam.user_roles SET valid_from=$3 WHERE user_id=$1 AND role_id=$2',[users[2].id,role,time]);
});
test('M1C runtime boundaries deny direct DML, owner SET ROLE and private command/audit bypass in both pools',async()=>{
 const relations=(await db.query("SELECT tablename FROM pg_tables WHERE schemaname='iam'")).rows.map(r=>r.tablename);
 for(const runtime of ['app_runtime','auth_runtime'])for(const name of relations)assert.equal((await db.query("SELECT has_table_privilege($1,$2,'INSERT,UPDATE,DELETE,TRUNCATE') AS writable",[runtime,'iam.'+name])).rows[0].writable,false,runtime+' must have no direct DML privilege on '+name);
 for(const url of [urls.app,urls.auth]){const c=new pg.Client({connectionString:url});await c.connect();try{
 for(const name of relations){for(const sql of [`DELETE FROM iam.${name}`,`UPDATE iam.${name} SET tableoid=tableoid`,`INSERT INTO iam.${name} DEFAULT VALUES`,`TRUNCATE iam.${name}`])await assert.rejects(c.query(sql),undefined,name+' DML');}
 for(const owner of ['sgp_context_owner','sgp_iam_executor_owner','sgp_audit_writer','sgp_object_owner','sgp_bootstrap_owner'])await assert.rejects(c.query('SET ROLE '+owner));
 await assert.rejects(c.query('SELECT iam.enroll_m1c($1,$2)',[users[0].id,users[1].id]));await assert.rejects(c.query('SELECT * FROM iam.request_bindings'));await assert.rejects(c.query('SELECT * FROM iam.user_credentials'));
 }finally{await c.end();}}
 const unsafe=(await db.query("SELECT count(*)::int AS n FROM pg_roles WHERE rolname IN('app_runtime','auth_runtime') AND (rolsuper OR rolbypassrls OR rolcreatedb OR rolcreaterole)")).rows[0].n;assert.equal(unsafe,0);
 const unforced=(await db.query("SELECT count(*)::int AS n FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='iam' AND c.relkind='r' AND NOT(c.relrowsecurity AND c.relforcerowsecurity)")).rows[0].n;assert.equal(unforced,0);
});
test('M1C forged GUC/context, unknown policy, search_path and CLOSED binding cannot authorize',async()=>{
 await tx(users[2].token,async(c,ctx)=>{
  const forged=(await c.query('SELECT iam.authorize($1,$2,$3,$4,$5) AS d',[users[0].id,'security.roles.read','IAM_ROLE',resources[0],ctx])).rows[0].d;assert.equal(forged.decision,'DENY');
  const unknown=(await c.query('SELECT iam.authorize($1,$2,$3,$4,$5) AS d',[ctx.user_id,'unknown.action','IAM_ROLE',resources[0],ctx])).rows[0].d;assert.equal(unknown.internal_reason,'POLICY_UNKNOWN');
  await c.query("SET LOCAL search_path=pg_temp,public,iam");assert.equal((await c.query('SELECT id FROM iam.roles WHERE id=$1',[resources[0]])).rowCount,1);
  for(const [key,value] of [['app.user_id',users[0].id],['app.clearance','forged'],['app.compartments','["forged"]']]){await c.query('SAVEPOINT guc');await c.query('SELECT set_config($1,$2,true)',[key,value]);assert.equal((await c.query('SELECT id FROM iam.roles')).rowCount,0);await c.query('ROLLBACK TO guc');}
  await c.query('SELECT iam.finish_request()');assert.equal((await c.query('SELECT id FROM iam.roles')).rowCount,0);await c.query('SAVEPOINT rebind');await assert.rejects(c.query('SELECT iam.bind_request($1,false,$2,$3,$4)',[users[3].token,...meta()]));await c.query('ROLLBACK TO rebind');
 });
 assert.equal((await api(users[2].token,'roles/'+randomUUID())).statusCode,404);assert.equal((await api('', 'roles')).statusCode,401);
});
test('M1C lists and counts share RLS pagination; direct API ignores no frontend permission claims',async()=>{
 const response=await api(users[2].token,'roles?limit=1&offset=0');assert.equal(response.statusCode,200,response.body);const sql=await tx(users[2].token,async c=>(await c.query('SELECT count(*)::int AS total FROM iam.roles')).rows[0].total);assert.equal(response.json().total,sql);assert.equal(response.json().items.length,1);
 const denied=await api(users[2].token,'roles',{code:'TEST_SELF_GRANT',scope_kind:'SCOPED',scope_id:scopes[0],classification_id:classes[0].id,compartments:[],privileged:false});assert.equal(denied.statusCode,403,denied.body);
 const forged=await api(users[2].token,'assignments',{actor_id:users[0].id,target_id:users[2].id,role_id:role,scope_kind:'SCOPED',scope_id:scopes[0],valid_from:time,valid_to:null,approval_id:null});assert.equal(forged.statusCode,400);
});
test('M1C typed role/permission/grant commands and immediate entitlement revocation E2E',async()=>{
 const made=await command(users[0],'roles',{code:'TEST_MANAGED_ROLE',scope_kind:'SCOPED',scope_id:scopes[0],classification_id:classes[0].id,compartments:[],privileged:false});assert.equal(made.statusCode,200,made.body);const id=made.json().id;
 const attach=await command(users[0],'role-permissions',{role_id:id,permission_id:permission,enabled:true});assert.equal(attach.statusCode,200,attach.body);
 // Remove the TEST pre-provisioned role so the subsequent real command is the only grant.
 await db.query('DELETE FROM iam.user_roles WHERE user_id=$1 AND role_id=$2',[users[4].id,role]);await matrix(users[4].token,resources[0],false,'before typed grant');
 const grant=await command(users[0],'assignments',{target_id:users[4].id,role_id:id,scope_kind:'SCOPED',scope_id:scopes[0],valid_from:time,valid_to:null,approval_id:null});assert.equal(grant.statusCode,200,grant.body);await matrix(users[4].token,resources[0],true,'typed grant');
 const revoke=await command(users[0],'assignment-revocations',{assignment_id:grant.json().id});assert.equal(revoke.statusCode,200,revoke.body);await matrix(users[4].token,resources[0],false,'revocation committed');
});
test('M1C maker/checker clearance elevation: self, payload forgery, policy drift and replay denied',async()=>{
 const payload={classification_id:classes[2].id,valid_from:time,valid_to:null};
 const req=await command(users[0],'approvals',{target_id:users[3].id,operation:'CLEARANCE_GRANT',payload,idempotency_key:randomUUID()});assert.equal(req.statusCode,200,req.body);const aid=req.json().id;
 const grant={target_id:users[3].id,...payload,approval_id:aid};
 assert.equal((await command(users[0],'clearances',grant)).statusCode,403);
 assert.equal((await command(users[1],'clearances',{...grant,classification_id:classes[3].id})).statusCode,403);
 const approved=await command(users[1],'clearances',grant);assert.equal(approved.statusCode,200,approved.body);assert.equal((await command(users[1],'clearances',grant)).statusCode,403,'approval replay');
 const state=(await db.query('SELECT state,approver_id FROM iam.approvals WHERE id=$1',[aid])).rows[0];assert.equal(state.state,'CONSUMED');assert.equal(state.approver_id,users[1].id);
 const second=await command(users[0],'approvals',{target_id:users[3].id,operation:'CLEARANCE_GRANT',payload:{...payload,classification_id:classes[3].id},idempotency_key:randomUUID()});assert.equal(second.statusCode,200,second.body);await db.query('UPDATE iam.security_policy_state SET version=version+1');assert.equal((await command(users[1],'clearances',{...grant,classification_id:classes[3].id,approval_id:second.json().id})).statusCode,403);
});
test('M1C audit append failure rolls back role creation and all authority effects',async()=>{
 const count=(await db.query('SELECT count(*)::int AS n FROM iam.roles')).rows[0].n;
 await db.query('REVOKE INSERT ON iam.authorization_events FROM sgp_audit_writer');try{const response=await command(users[0],'roles',{code:'TEST_AUDIT_ROLLBACK',scope_kind:'SCOPED',scope_id:scopes[0],classification_id:classes[0].id,compartments:[],privileged:false});assert.equal(response.statusCode,503,response.body);assert.equal((await db.query('SELECT count(*)::int AS n FROM iam.roles')).rows[0].n,count);}finally{await db.query('GRANT INSERT ON iam.authorization_events TO sgp_audit_writer');}
 const events=(await db.query('SELECT * FROM iam.authorization_events')).rows;assert.ok(events.length>10);assert.ok(events.every(e=>e.actor_id&&e.session_id&&e.request_id&&e.correlation_id&&e.decision_id&&e.policy_version&&e.occurred_at));assert.ok(!JSON.stringify(events).includes('password_hash'));
});

test('M1C SoD temporal: future overlap and indirect role permission conflict rollback; adjacent intervals allowed',async()=>{
 const a=(await db.query("INSERT INTO iam.roles(code) VALUES('TEST_SOD_A') RETURNING id")).rows[0].id;
 const b=(await db.query("INSERT INTO iam.roles(code) VALUES('TEST_SOD_B') RETURNING id")).rows[0].id;
 for(const r of [a,b]){await db.query('INSERT INTO iam.role_permissions VALUES($1,$2)',[r,permission]);await db.query("INSERT INTO iam.resource_security VALUES('IAM_ROLE',$1,'SCOPED',$2,NULL,$3,true,'PASSWORD')",[r,scopes[0],classes[0].id]);}
 await db.query('INSERT INTO iam.incompatible_roles(left_id,right_id) VALUES(least($1::uuid,$2::uuid),greatest($1::uuid,$2::uuid))',[a,b]);
 const tomorrow=new Date(Date.now()+86400000).toISOString(),end=new Date(Date.now()+172800000).toISOString();
 const grant=roleId=>({target_id:users[3].id,role_id:roleId,scope_kind:'SCOPED',scope_id:scopes[0],valid_from:tomorrow,valid_to:end,approval_id:null});
 assert.equal((await command(users[0],'assignments',grant(a))).statusCode,200);
 const rejected=await command(users[0],'assignments',grant(b));assert.equal(rejected.statusCode,403,rejected.body);assert.equal((await db.query('SELECT count(*)::int AS n FROM iam.user_roles WHERE user_id=$1 AND role_id=$2',[users[3].id,b])).rows[0].n,0);
 assert.equal((await command(users[0],'assignments',{...grant(b),valid_from:end,valid_to:null})).statusCode,200);
 const p=(await db.query("SELECT id FROM iam.permissions WHERE code='security.users.read'")).rows[0].id;
 await db.query('INSERT INTO iam.incompatible_permissions(left_id,right_id) VALUES(least($1::uuid,$2::uuid),greatest($1::uuid,$2::uuid))',[permission,p]);
 // The TEST constraint would also invalidate founders if applied to their full role.
 // Isolate the affected permissions by removing their TEST founder links temporarily.
 const founder=(await db.query("SELECT id FROM iam.roles WHERE code='SECURITY_BOOTSTRAP_OPERATOR'")).rows[0].id;
 await db.query('DELETE FROM iam.role_permissions WHERE role_id=$1 AND permission_id=$2',[founder,p]);
 try{const edit=await command(users[0],'role-permissions',{role_id:a,permission_id:p,enabled:true});assert.equal(edit.statusCode,403,edit.body);assert.equal((await db.query('SELECT count(*)::int AS n FROM iam.role_permissions WHERE role_id=$1 AND permission_id=$2',[a,p])).rows[0].n,0);}finally{await db.query('DELETE FROM iam.incompatible_permissions');await db.query('INSERT INTO iam.role_permissions VALUES($1,$2)',[founder,p]);}
});

test('M1C delegation is explicit and scoped; self escalation, own role edits, cross-scope and expired authority deny',async()=>{
 const own=(await db.query("SELECT id FROM iam.roles WHERE code='SECURITY_BOOTSTRAP_OPERATOR'")).rows[0].id;
 assert.equal((await command(users[0],'role-permissions',{role_id:own,permission_id:permission,enabled:true})).statusCode,403);
 assert.equal((await command(users[0],'assignments',{target_id:users[0].id,role_id:role,scope_kind:'IAM_GLOBAL',scope_id:null,valid_from:time,valid_to:null,approval_id:null})).statusCode,403);
 for(const [path,extra] of [['clearances',{classification_id:classes[4].id}],['compartments',{compartment_id:compartments[0]}]])assert.equal((await command(users[0],path,{target_id:users[0].id,...extra,valid_from:time,valid_to:null,approval_id:null})).statusCode,403);
 const create={code:'TEST_NO_DELEGATION',scope_kind:'SCOPED',scope_id:scopes[0],classification_id:classes[0].id,compartments:[],privileged:false};
 await db.query("UPDATE iam.delegation_authority SET valid_to=clock_timestamp()-interval '1 second' WHERE user_id=$1 AND permission_id=(SELECT id FROM iam.permissions WHERE code='security.roles.manage') AND scope_kind='SCOPED'",[users[0].id]);
 try{assert.equal((await command(users[0],'roles',create)).statusCode,403);}finally{await db.query("UPDATE iam.delegation_authority SET valid_to=NULL WHERE user_id=$1 AND permission_id=(SELECT id FROM iam.permissions WHERE code='security.roles.manage') AND scope_kind='SCOPED'",[users[0].id]);}
 assert.equal((await command(users[0],'roles',{...create,scope_id:scopes[1]})).statusCode,403);
});

test('M1C pool max=1 and savepoints cannot preserve an effect under a different identity',async()=>{
 const c=await pool.connect();try{
 await c.query('BEGIN');await c.query('SAVEPOINT before_bind');await c.query('SELECT iam.bind_request($1,false,$2,$3,$4)',[users[2].token,...meta()]);
 const ctx=(await c.query('SELECT iam.bound_context() AS ctx')).rows[0].ctx;const before=(await db.query('SELECT count(*)::int AS n FROM iam.authorization_events')).rows[0].n;
 await c.query('SELECT iam.authorize($1,$2,$3,$4,$5)',[ctx.user_id,'security.roles.read','IAM_ROLE',resources[0],ctx]);await c.query('ROLLBACK TO before_bind');
 const b=(await c.query('SELECT iam.bind_request($1,false,$2,$3,$4) AS ctx',[users[3].token,...meta()])).rows[0].ctx;assert.equal(b.user_id,users[3].id);await c.query('SAVEPOINT after_bind');await c.query('SELECT iam.finish_request()');await c.query('ROLLBACK TO after_bind');assert.equal((await c.query('SELECT iam.bound_context() AS ctx')).rows[0].ctx.user_id,users[3].id);
 await c.query('SAVEPOINT bad_rebind');await assert.rejects(c.query('SELECT iam.bind_request($1,false,$2,$3,$4)',[users[2].token,...meta()]));await c.query('ROLLBACK TO bad_rebind');await c.query('COMMIT');assert.equal((await db.query('SELECT count(*)::int AS n FROM iam.authorization_events')).rows[0].n,before,'rolled-back identity effect must not survive');
 await c.query('BEGIN');assert.equal((await c.query('SELECT iam.bound_context() AS ctx')).rows[0].ctx,null);await c.query('SELECT iam.bind_request($1,false,$2,$3,$4)',[users[2].token,...meta()]);await c.query('ROLLBACK');
 await c.query('BEGIN');await c.query("SET LOCAL statement_timeout='50ms'");await assert.rejects(c.query('SELECT pg_sleep(0.2)'));await c.query('ROLLBACK');assert.equal((await c.query('SELECT iam.bound_context() AS ctx')).rows[0].ctx,null);
 }finally{c.release();}
 await matrix(users[3].token,resources[0],true,'next user after timeout');
});

test('M1C real RLS USING / WITH CHECK gates INSERT, UPDATE new state and independent DELETE',async()=>{
 // These technical resources exist only in the disposable TEST database, with no operational route.
 await db.query(`CREATE SCHEMA test_policy;GRANT USAGE ON SCHEMA test_policy TO app_runtime,sgp_context_owner;
 CREATE TABLE test_policy.resources(id uuid PRIMARY KEY,scope_id uuid NOT NULL,classification_id uuid NOT NULL,compartments uuid[] NOT NULL,complete boolean NOT NULL);
 ALTER TABLE test_policy.resources ENABLE ROW LEVEL SECURITY;ALTER TABLE test_policy.resources FORCE ROW LEVEL SECURITY;
 CREATE FUNCTION test_policy.allowed(a text,s uuid,c uuid,cs uuid[],complete boolean) RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS 'SELECT iam.decision(a,''IAM_IDENTITY'',''SCOPED'',s,NULL,c,complete,cs,''PASSWORD'')->>''decision''=''ALLOW''';
 ALTER FUNCTION test_policy.allowed OWNER TO sgp_context_owner;REVOKE ALL ON FUNCTION test_policy.allowed FROM PUBLIC;GRANT EXECUTE ON FUNCTION test_policy.allowed TO app_runtime;
 CREATE POLICY read_resources ON test_policy.resources FOR SELECT TO app_runtime USING(test_policy.allowed('security.users.read',scope_id,classification_id,compartments,complete));
 CREATE POLICY insert_resources ON test_policy.resources FOR INSERT TO app_runtime WITH CHECK(test_policy.allowed('security.users.create',scope_id,classification_id,compartments,complete));
 CREATE POLICY update_resources ON test_policy.resources FOR UPDATE TO app_runtime USING(test_policy.allowed('security.users.update',scope_id,classification_id,compartments,complete)) WITH CHECK(test_policy.allowed('security.users.update',scope_id,classification_id,compartments,complete));
 CREATE POLICY delete_resources ON test_policy.resources FOR DELETE TO app_runtime USING(test_policy.allowed('security.users.disable',scope_id,classification_id,compartments,complete));
 GRANT SELECT,INSERT,UPDATE,DELETE ON test_policy.resources TO app_runtime;`);
 const r=(await db.query("INSERT INTO iam.roles(code) VALUES('TEST_WRITER') RETURNING id")).rows[0].id;
 await db.query("INSERT INTO iam.role_permissions SELECT $1,id FROM iam.permissions WHERE code IN('security.users.read','security.users.create','security.users.update')",[r]);
 await db.query("INSERT INTO iam.user_roles(user_id,role_id,scope_kind,scope_id,valid_from) VALUES($1,$2,'SCOPED',$3,$4)",[users[4].id,r,scopes[0],time]);
 const id=randomUUID();await tx(users[4].token,c=>c.query('INSERT INTO test_policy.resources VALUES($1,$2,$3,$4,true)',[id,scopes[0],classes[0].id,[]]));
 await assert.rejects(tx(users[4].token,c=>c.query('INSERT INTO test_policy.resources VALUES($1,$2,$3,$4,true)',[randomUUID(),scopes[1],classes[0].id,[]])));
 for(const [column,value] of [['scope_id',scopes[1]],['classification_id',classes[4].id],['compartments',compartments]])await assert.rejects(tx(users[4].token,c=>c.query(`UPDATE test_policy.resources SET ${column}=$1 WHERE id=$2`,[value,id])));
 assert.equal(await tx(users[4].token,async c=>(await c.query('DELETE FROM test_policy.resources WHERE id=$1',[id])).rowCount),0,'update capability does not imply delete');
 assert.equal((await db.query('SELECT scope_id,classification_id FROM test_policy.resources WHERE id=$1',[id])).rows[0].scope_id,scopes[0]);
});

test('M1C revocation waits for earlier authorization; two concurrent operator removals both deny',async()=>{
 const requestClient=new pg.Client({connectionString:urls.app}),revoker=new pg.Client({connectionString:urls.app});await requestClient.connect();await revoker.connect();
 // Use a read-only grant created solely for this revocation proof.
 const r=(await db.query("INSERT INTO iam.roles(code) VALUES('TEST_REVOKE_READER') RETURNING id")).rows[0].id;await db.query('INSERT INTO iam.role_permissions VALUES($1,$2)',[r,permission]);const assignment=(await db.query("INSERT INTO iam.user_roles(user_id,role_id,scope_kind,scope_id,valid_from) VALUES($1,$2,'SCOPED',$3,$4) RETURNING id",[users[4].id,r,scopes[0],time])).rows[0].id;
 try{
 await requestClient.query('BEGIN');await requestClient.query('SELECT iam.bind_request($1,false,$2,$3,$4)',[users[4].token,...meta()]);assert.equal((await requestClient.query('SELECT id FROM iam.roles WHERE id=$1',[resources[0]])).rowCount,1);
 const revoke=revoker.query('SELECT iam.revoke_assignment($1,$2,$3,$4,$5,$6)',[users[0].token,csrfFor(users[0].token),assignment,...meta()]);
 let waiting=false;for(let i=0;i<30;i++){const rows=await db.query("SELECT wait_event_type FROM pg_stat_activity WHERE pid=$1",[revoker.processID]);if(rows.rows[0]?.wait_event_type==='Lock'){waiting=true;break;}await new Promise(resolve=>setTimeout(resolve,10));}assert.ok(waiting,'revocation must wait');
 await requestClient.query('COMMIT');await revoke;await matrix(users[4].token,resources[0],false,'after revocation linearization');
 }finally{await requestClient.query('ROLLBACK');await requestClient.end();await revoker.end();}
 const remove=(actor,target)=>app.inject({method:'POST',url:'/api/v1/auth/admin/account-command',headers:{origin,'x-forwarded-proto':'https',cookie:'__Host-sgp_session='+actor.token,'x-csrf-token':csrfFor(actor.token)},payload:{target_id:target.id,action:'DISABLED'}});
 const results=await Promise.all([remove(users[0],users[1]),remove(users[1],users[0])]);assert.deepEqual(results.map(r=>r.statusCode),[403,403]);assert.equal((await db.query("SELECT count(*)::int AS n FROM iam.users WHERE id=ANY($1) AND status='ACTIVE'",[users.slice(0,2).map(u=>u.id)])).rows[0].n,2);
});

test('M1C location belongs to the same grant; inactive compartment and inactive classification deny',async()=>{
 await db.query("UPDATE iam.resource_security SET location_id=$1 WHERE resource_type='IAM_ROLE' AND resource_id=$2",[scopes[1],resources[0]]);
 try{
  await matrix(users[2].token,resources[0],false,'required location absent');
  const assignment=(await db.query('SELECT id FROM iam.user_roles WHERE user_id=$1 AND role_id=$2',[users[2].id,role])).rows[0].id;
  await db.query('INSERT INTO iam.user_location_bindings VALUES($1,$2,$3,NULL)',[assignment,scopes[1],time]);await matrix(users[2].token,resources[0],true,'same grant location');
  await db.query("UPDATE iam.user_location_bindings SET valid_to=clock_timestamp()-interval '1 second' WHERE assignment_id=$1",[assignment]);await matrix(users[2].token,resources[0],false,'expired location');
 }finally{await db.query("UPDATE iam.resource_security SET location_id=NULL WHERE resource_type='IAM_ROLE' AND resource_id=$1",[resources[0]]);}
 await db.query("UPDATE iam.security_compartments SET status='INACTIVE' WHERE id=$1",[compartments[1]]);try{await matrix(users[2].token,resources[3],false,'required compartment inactive');}finally{await db.query("UPDATE iam.security_compartments SET status='ACTIVE' WHERE id=$1",[compartments[1]]);}
 await db.query("UPDATE iam.security_classifications SET status='INACTIVE' WHERE id=$1",[classes[0].id]);try{await matrix(users[2].token,resources[0],false,'resource classification inactive');}finally{await db.query("UPDATE iam.security_classifications SET status='ACTIVE' WHERE id=$1",[classes[0].id]);}
});

test('M1C every typed executor denies unauthorized, expired, revoked, tampered, cross-scope and direct SQL bypass',async()=>{
 const create={code:'TEST_NEGATIVE_ROLE',scope_kind:'SCOPED',scope_id:scopes[0],classification_id:classes[0].id,compartments:[],privileged:false};
 const made=await command(users[0],'roles',create);assert.equal(made.statusCode,200,made.body);const r=made.json().id;
 assert.equal((await command(users[0],'role-permissions',{role_id:r,permission_id:permission,enabled:true})).statusCode,200);
 const assignment=await command(users[0],'assignments',{target_id:users[4].id,role_id:r,scope_kind:'SCOPED',scope_id:scopes[0],valid_from:time,valid_to:null,approval_id:null});assert.equal(assignment.statusCode,200,assignment.body);
 const cases=[
  ['roles',{...create,code:'TEST_NEGATIVE_DENIED'},'SELECT iam.create_role($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)',v=>[v.code,v.scope_kind,v.scope_id,v.classification_id,v.compartments,v.privileged]],
  ['role-permissions',{role_id:r,permission_id:permission,enabled:false},'SELECT iam.set_role_permission($1,$2,$3,$4,$5,$6,$7,$8)',v=>[v.role_id,v.permission_id,v.enabled]],
  ['approvals',{target_id:users[4].id,operation:'CLEARANCE_GRANT',payload:{classification_id:classes[2].id,valid_from:time,valid_to:null},idempotency_key:randomUUID()},'SELECT iam.request_approval($1,$2,$3,$4,$5,$6,$7,$8,$9)',v=>[v.target_id,v.operation,v.payload,v.idempotency_key]],
  ['assignments',{target_id:users[4].id,role_id:r,scope_kind:'SCOPED',scope_id:scopes[0],valid_from:time,valid_to:null,approval_id:null},'SELECT iam.assign_role($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)',v=>[v.target_id,v.role_id,v.scope_kind,v.scope_id,v.valid_from,v.valid_to,v.approval_id]],
  ['clearances',{target_id:users[4].id,classification_id:classes[1].id,valid_from:time,valid_to:null,approval_id:null},'SELECT iam.grant_clearance($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',v=>[v.target_id,v.classification_id,v.valid_from,v.valid_to,v.approval_id]],
  ['compartments',{target_id:users[4].id,compartment_id:compartments[0],valid_from:time,valid_to:null,approval_id:null},'SELECT iam.grant_compartment($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',v=>[v.target_id,v.compartment_id,v.valid_from,v.valid_to,v.approval_id]],
  ['assignment-revocations',{assignment_id:assignment.json().id},'SELECT iam.revoke_assignment($1,$2,$3,$4,$5,$6)',v=>[v.assignment_id]],
 ];
 for(const [path,payload] of cases){assert.equal((await command(users[2],path,payload)).statusCode,403,path+' unauthorized');
  const response=await app.inject({method:'POST',url:'/api/v1/security/'+path,headers:{origin,'x-forwarded-proto':'https',cookie:'__Host-sgp_session='+users[0].token,'x-csrf-token':fresh()},payload});assert.equal(response.statusCode,403,path+' CSRF tamper');}
 await db.query("UPDATE iam.user_roles SET valid_to=clock_timestamp()-interval '1 second' WHERE user_id=$1",[users[0].id]);try{for(const [path,payload] of cases)assert.equal((await command(users[0],path,payload)).statusCode,403,path+' expired grant');}finally{await db.query('UPDATE iam.user_roles SET valid_to=NULL WHERE user_id=$1',[users[0].id]);}
 await db.query("UPDATE iam.sessions SET revoked_at=clock_timestamp() WHERE token_hash=iam_crypto.digest($1,'sha256')",[users[0].token]);try{for(const [path,payload] of cases)assert.equal((await command(users[0],path,payload)).statusCode,401,path+' revoked session');}finally{await db.query("UPDATE iam.sessions SET revoked_at=NULL WHERE token_hash=iam_crypto.digest($1,'sha256')",[users[0].token]);}
 await db.query("UPDATE iam.resource_security SET scope_id=$1 WHERE (resource_type='IAM_IDENTITY' AND resource_id=$2) OR (resource_type='IAM_ROLE' AND resource_id=$3)",[scopes[1],users[4].id,r]);try{for(const [path,payload] of cases){const p=path==='roles'?{...payload,scope_id:scopes[1]}:payload;assert.equal((await command(users[0],path,p)).statusCode,403,path+' cross scope');}}finally{await db.query("UPDATE iam.resource_security SET scope_id=$1 WHERE (resource_type='IAM_IDENTITY' AND resource_id=$2) OR (resource_type='IAM_ROLE' AND resource_id=$3)",[scopes[0],users[4].id,r]);}
 for(const [url,person] of [[urls.app,users[2]],[urls.auth,users[0]]]){const c=new pg.Client({connectionString:url});await c.connect();try{for(const [path,payload,sql,args] of cases)await assert.rejects(c.query(sql,[person.token,csrfFor(person.token),...args(payload),...meta()]),undefined,path+' direct SQL');}finally{await c.end();}}
 const granted=await command(users[0],'compartments',{target_id:users[4].id,compartment_id:compartments[0],valid_from:time,valid_to:null,approval_id:null});assert.equal(granted.statusCode,200,granted.body);
 const audit=await api(users[0].token,'audit?limit=100&offset=0');assert.equal(audit.statusCode,200,audit.body);assert.ok(audit.json().items.some(e=>e.result==='DENY'));assert.ok(audit.json().items.some(e=>e.action==='security.compartments.manage'&&e.result==='ALLOW'));
});

test('M1C principal E2E: operator configures role/grants/clearance/compartment, new login, scoped access and audit reconstruction',async()=>{
 const person={username:'test_e2e_'+randomUUID().slice(0,8),display_name:'TEST M1C ephemeral subject',password:fresh()};const passwords=await PasswordService.create();
 person.id=(await db.query("INSERT INTO iam.users(username,display_name,status) VALUES($1,$2,'ACTIVE') RETURNING id",[person.username,person.display_name])).rows[0].id;await db.query('INSERT INTO iam.user_credentials(user_id,password_hash) VALUES($1,$2)',[person.id,await passwords.hash(person.password)]);await db.query("INSERT INTO iam.user_security_attributes VALUES($1,'ACTIVE')",[person.id]);await db.query("INSERT INTO iam.resource_security VALUES('IAM_IDENTITY',$1,'SCOPED',$2,NULL,$3,true,'PASSWORD')",[person.id,scopes[0],classes[0].id]);await db.query('INSERT INTO iam.security_clearances VALUES($1,$2,$3,NULL,$4)',[person.id,classes[0].id,time,users[0].id]);
 const created=await command(users[0],'roles',{code:'TEST_END_TO_END',scope_kind:'SCOPED',scope_id:scopes[0],classification_id:classes[0].id,compartments:[],privileged:false});assert.equal(created.statusCode,200,created.body);const r=created.json().id;
 assert.equal((await command(users[0],'role-permissions',{role_id:r,permission_id:permission,enabled:true})).statusCode,200);
 assert.equal((await command(users[0],'assignments',{target_id:person.id,role_id:r,scope_kind:'SCOPED',scope_id:scopes[0],valid_from:time,valid_to:null,approval_id:null})).statusCode,200);
 const payload={classification_id:classes[1].id,valid_from:time,valid_to:null};const approval=await command(users[0],'approvals',{target_id:person.id,operation:'CLEARANCE_GRANT',payload,idempotency_key:randomUUID()});assert.equal(approval.statusCode,200,approval.body);
 assert.equal((await command(users[1],'clearances',{target_id:person.id,...payload,approval_id:approval.json().id})).statusCode,200);
 assert.equal((await command(users[0],'compartments',{target_id:person.id,compartment_id:compartments[0],valid_from:time,valid_to:null,approval_id:null})).statusCode,200);
 person.token=await login(person);await matrix(person.token,resources[0],true,'end-to-end allowed');await matrix(person.token,resources[1],false,'end-to-end other scope');await matrix(person.token,resources[2],false,'end-to-end above clearance');await matrix(person.token,resources[3],false,'end-to-end missing second compartment');
 const events=(await db.query('SELECT action,result,decision_id FROM iam.authorization_events WHERE target_id=$1 OR actor_id=$1',[person.id])).rows;assert.ok(events.some(e=>e.action==='security.assignments.manage'&&e.result==='ALLOW'));assert.ok(events.some(e=>e.action==='security.clearances.manage'&&e.result==='ALLOW'));assert.ok(events.some(e=>e.action==='security.compartments.manage'&&e.result==='ALLOW'));assert.equal(events.filter(e=>e.action==='security.roles.read'&&e.result==='DENY').length,6);
});

test('M1C privileged role approval and sensitive compartment require distinct authorized checker; capacity expiry and forgeries deny',async()=>{
 const made=await command(users[0],'roles',{code:'TEST_PRIVILEGED_ROLE',scope_kind:'SCOPED',scope_id:scopes[0],classification_id:classes[0].id,compartments:[],privileged:true});assert.equal(made.statusCode,200,made.body);const r=made.json().id;
 const p=(await db.query("SELECT id FROM iam.permissions WHERE code='security.users.update'")).rows[0].id;assert.equal((await command(users[0],'role-permissions',{role_id:r,permission_id:p,enabled:true})).statusCode,200);
 const payload={role_id:r,scope_kind:'SCOPED',scope_id:scopes[0],valid_from:time,valid_to:null};const grant={target_id:users[4].id,...payload,approval_id:null};assert.equal((await command(users[0],'assignments',grant)).statusCode,403);
 const request=await command(users[0],'approvals',{target_id:users[4].id,operation:'ROLE_GRANT',payload,idempotency_key:randomUUID()});assert.equal(request.statusCode,200,request.body);grant.approval_id=request.json().id;
 assert.equal((await command(users[0],'assignments',grant)).statusCode,403);assert.equal((await command(users[1],'assignments',{...grant,valid_to:new Date(Date.now()+3600000).toISOString()})).statusCode,403);assert.equal((await command(users[1],'assignments',grant)).statusCode,200);assert.equal((await command(users[1],'assignments',grant)).statusCode,403);
 const id=compartments[1];await db.query('UPDATE iam.security_compartments SET sensitive=true WHERE id=$1',[id]);const cp={compartment_id:id,valid_from:time,valid_to:null};const cgrant={target_id:users[4].id,...cp,approval_id:null};assert.equal((await command(users[0],'compartments',cgrant)).statusCode,403);
 const crequest=await command(users[0],'approvals',{target_id:users[4].id,operation:'COMPARTMENT_GRANT',payload:cp,idempotency_key:randomUUID()});assert.equal(crequest.statusCode,200,crequest.body);cgrant.approval_id=crequest.json().id;assert.equal((await command(users[0],'compartments',cgrant)).statusCode,403);assert.equal((await command(users[1],'compartments',cgrant)).statusCode,200);assert.equal((await command(users[1],'compartments',cgrant)).statusCode,403);
 const forged=await command(users[0],'approvals',{target_id:users[4].id,operation:'CLEARANCE_GRANT',payload:{classification_id:classes[3].id,valid_from:time,valid_to:null,approver_id:users[0].id},idempotency_key:randomUUID()});assert.equal(forged.statusCode,403);
 // Scheduling loss of the other founder's permanent baseline clearance is rejected.
 assert.equal((await command(users[0],'clearances',{target_id:users[1].id,classification_id:classes[4].id,valid_from:time,valid_to:new Date(Date.now()+3600000).toISOString(),approval_id:null})).statusCode,200);
 const expires=await command(users[0],'clearances',{target_id:users[1].id,classification_id:classes[0].id,valid_from:time,valid_to:new Date(Date.now()+3600000).toISOString(),approval_id:null});assert.equal(expires.statusCode,403,expires.body);
 assert.equal((await db.query('SELECT valid_to FROM iam.security_clearances WHERE user_id=$1 AND classification_id=$2',[users[1].id,classes[0].id])).rows[0].valid_to,null);
});

test('M1C approval revalidates maker compartment at execution and rejects expired approval',async()=>{
 await db.query("INSERT INTO iam.resource_compartments VALUES('IAM_IDENTITY',$1,$2)",[users[4].id,compartments[1]]);
 try{
  const payload={classification_id:classes[3].id,valid_from:time,valid_to:null};const request=await command(users[0],'approvals',{target_id:users[4].id,operation:'CLEARANCE_GRANT',payload,idempotency_key:randomUUID()});assert.equal(request.statusCode,200,request.body);const aid=request.json().id;
  await db.query("UPDATE iam.user_compartments SET valid_to=clock_timestamp()-interval '1 second' WHERE user_id=$1 AND compartment_id=$2",[users[0].id,compartments[1]]);
  try{assert.equal((await command(users[1],'clearances',{target_id:users[4].id,...payload,approval_id:aid})).statusCode,403,'maker lost required compartment');}finally{await db.query('UPDATE iam.user_compartments SET valid_to=NULL WHERE user_id=$1 AND compartment_id=$2',[users[0].id,compartments[1]]);}
  await db.query("UPDATE iam.approvals SET valid_until=clock_timestamp()-interval '1 second' WHERE id=$1",[aid]);assert.equal((await command(users[1],'clearances',{target_id:users[4].id,...payload,approval_id:aid})).statusCode,403,'expired approval');assert.equal((await db.query('SELECT state FROM iam.approvals WHERE id=$1',[aid])).rows[0].state,'PENDING');
 }finally{await db.query("DELETE FROM iam.resource_compartments WHERE resource_type='IAM_IDENTITY' AND resource_id=$1",[users[4].id]);}
});

test('M1C every classification threshold is parametrized; inactive employment and revoked subject fail closed',async()=>{
 try{for(let rank=0;rank<classes.length;rank++){
  await db.query('DELETE FROM iam.security_clearances WHERE user_id=$1',[users[2].id]);await db.query('INSERT INTO iam.security_clearances VALUES($1,$2,$3,NULL,$4)',[users[2].id,classes[rank].id,time,users[0].id]);
  await db.query("UPDATE iam.resource_security SET classification_id=$1 WHERE resource_type='IAM_ROLE' AND resource_id=$2",[classes[rank].id,resources[0]]);await matrix(users[2].token,resources[0],true,'rank equality '+rank);
  if(rank+1<classes.length){await db.query("UPDATE iam.resource_security SET classification_id=$1 WHERE resource_type='IAM_ROLE' AND resource_id=$2",[classes[rank+1].id,resources[0]]);await matrix(users[2].token,resources[0],false,'rank insufficient '+rank);}
 }}finally{await db.query("UPDATE iam.resource_security SET classification_id=$1 WHERE resource_type='IAM_ROLE' AND resource_id=$2",[classes[0].id,resources[0]]);}
 await db.query("UPDATE iam.user_security_attributes SET employment_status='INACTIVE' WHERE user_id=$1",[users[2].id]);try{const d=await matrix(users[2].token,resources[0],false,'employment inactive');assert.equal(d.internal_reason,'USER_INACTIVE');}finally{await db.query("UPDATE iam.user_security_attributes SET employment_status='ACTIVE' WHERE user_id=$1",[users[2].id]);}
 await db.query("UPDATE iam.users SET status='DISABLED',subject_version=subject_version+1 WHERE id=$1",[users[2].id]);assert.equal((await api(users[2].token,'roles')).statusCode,401);
});

test('M1C HIGH-001: temporal clearance expansion requires exact maker/checker approval',async()=>{
 const target=users[4].id,rank1=classes[1].id;
 const finite1=new Date(Date.now()+3600000).toISOString(),finite2=new Date(Date.now()+7200000).toISOString();
 const read=async(id=rank1)=>(await db.query('SELECT valid_from,valid_to FROM iam.security_clearances WHERE user_id=$1 AND classification_id=$2',[target,id])).rows[0];
 const grant=(person,classification_id,valid_to,approval_id=null,valid_from=time)=>command(person,'clearances',{target_id:target,classification_id,valid_from,valid_to,approval_id});
 const approve=async(classification_id,valid_to,valid_from=time)=>{
  const request=await command(users[0],'approvals',{target_id:target,operation:'CLEARANCE_GRANT',payload:{classification_id,valid_from,valid_to},idempotency_key:randomUUID()});
  assert.equal(request.statusCode,200,request.body);return request.json().id;
 };
 await db.query('UPDATE iam.security_clearances SET valid_from=$3,valid_to=$4 WHERE user_id=$1 AND classification_id=$2',[target,rank1,time,finite1]);
 const old=await read();assert.ok(old.valid_to,'finite TEST starting state');
 const version=async()=>(await db.query('SELECT version FROM iam.security_policy_state WHERE id')).rows[0].version;
 const baselineVersion=await version();
 assert.equal((await grant(users[0],rank1,null)).statusCode,403,'finite to unbounded direct API must deny');
 assert.equal((await read()).valid_to.toISOString(),old.valid_to.toISOString());assert.equal(await version(),baselineVersion);
 const direct=new pg.Client({connectionString:urls.app});await direct.connect();
 try{await assert.rejects(direct.query('SELECT iam.grant_clearance($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',[users[0].token,csrfFor(users[0].token),target,rank1,time,null,null,...meta()]),error=>error.code==='PT403','direct SQL executor cannot bypass approval');}finally{await direct.end();}
 const rejection=(await db.query("SELECT actor_id,target_id,action,result,reason,request_id,correlation_id,policy_version,after_state FROM iam.authorization_events WHERE target_id=$1 AND action='security.clearances.manage' AND result='DENY' ORDER BY occurred_at DESC LIMIT 1",[target])).rows[0];
 assert.equal(rejection.actor_id,users[0].id);assert.equal(rejection.target_id,target);assert.ok(rejection.request_id&&rejection.correlation_id&&rejection.policy_version);assert.equal(rejection.result,'DENY');assert.equal(rejection.after_state.requested_change.classification_id,rank1);assert.equal(rejection.after_state.requested_change.valid_to,null);
 const aid=await approve(rank1,null);
 const stored=(await db.query('SELECT payload,policy_version FROM iam.approvals WHERE id=$1',[aid])).rows[0];
 assert.equal(stored.payload.target_user,target);assert.equal(Date.parse(stored.payload.old_clearance.valid_to),Date.parse(finite1));assert.equal(stored.payload.new_clearance.valid_to,null);assert.equal(stored.payload.policy_version,Number(stored.policy_version));
 assert.equal((await grant(users[0],rank1,null,aid)).statusCode,403,'maker is not checker');
 assert.equal((await grant(users[1],rank1,finite2,aid)).statusCode,403,'approval binds new interval');
 assert.equal((await grant(users[1],rank1,null,aid)).statusCode,200,'distinct checker executes exact approval');
 assert.equal((await read()).valid_to,null);assert.equal((await db.query('SELECT state FROM iam.approvals WHERE id=$1',[aid])).rows[0].state,'CONSUMED');assert.equal(Number(await version()),Number(baselineVersion)+1);
 const allowed=(await db.query("SELECT before_state,after_state,decision_id,request_id,correlation_id FROM iam.authorization_events WHERE target_id=$1 AND action='security.clearances.manage' AND result='ALLOW' ORDER BY occurred_at DESC LIMIT 1",[target])).rows[0];
 assert.equal(Date.parse(allowed.before_state.valid_to),Date.parse(finite1));assert.equal(allowed.after_state.approval_id,aid);assert.equal(allowed.after_state.maker_id,users[0].id);assert.equal(allowed.after_state.checker_id,users[1].id);assert.ok(allowed.decision_id&&allowed.request_id&&allowed.correlation_id);
 assert.equal((await grant(users[1],rank1,null,aid)).statusCode,403,'consumed approval cannot replay even when state matches');
 await db.query('UPDATE iam.security_clearances SET valid_to=$3 WHERE user_id=$1 AND classification_id=$2',[target,rank1,finite1]);
 assert.equal((await grant(users[0],rank1,finite2)).statusCode,403,'finite to later finite is elevation');
 const laterApproval=await approve(rank1,finite2);assert.equal((await grant(users[1],rank1,finite2,laterApproval)).statusCode,200);
 assert.equal((await read()).valid_to.toISOString(),new Date(finite2).toISOString());
 assert.equal((await grant(users[0],rank1,finite1)).statusCode,200,'shorter interval is reduction');
 assert.equal((await read()).valid_to.toISOString(),new Date(finite1).toISOString());
 const earlier=new Date(Date.parse(time)-3600000).toISOString();assert.equal((await grant(users[0],rank1,finite1,null,earlier)).statusCode,403,'earlier start expands authority');
 const higher=classes[2].id;assert.equal((await grant(users[0],higher,null)).statusCode,403,'rank and time expansion');
 const higherApproval=await approve(higher,null);assert.equal((await grant(users[1],higher,null,higherApproval)).statusCode,200);
 assert.equal((await grant(users[0],higher,null,null)).statusCode,200,'already covered interval is not new authority');
 assert.equal((await command(users[0],'clearances',{target_id:users[0].id,classification_id:classes[3].id,valid_from:time,valid_to:null,approval_id:null})).statusCode,403,'self grant');
 for(const url of [urls.app,urls.auth]){
  const c=new pg.Client({connectionString:url});await c.connect();try{await assert.rejects(c.query('UPDATE iam.security_clearances SET valid_to=NULL WHERE user_id=$1 AND classification_id=$2',[target,rank1]));}finally{await c.end();}
 }
});

test('M1C HIGH-001: approval rejects expired maker/checker authority, stale policy and old-state drift',async()=>{
 const target=users[4].id,classification_id=classes[3].id;
 const payload={classification_id,valid_from:time,valid_to:null};
 const request=async()=>{
  const r=await command(users[0],'approvals',{target_id:target,operation:'CLEARANCE_GRANT',payload,idempotency_key:randomUUID()});assert.equal(r.statusCode,200,r.body);return r.json().id;
 };
 const execute=aid=>command(users[1],'clearances',{target_id:target,...payload,approval_id:aid});
 const aid=await request();
 await db.query("UPDATE iam.security_clearances SET valid_to=clock_timestamp()-interval '1 second' WHERE user_id=$1 AND classification_id=$2",[users[0].id,classes[4].id]);
 try{assert.equal((await execute(aid)).statusCode,403,'maker authority expired');}finally{await db.query('UPDATE iam.security_clearances SET valid_to=NULL WHERE user_id=$1 AND classification_id=$2',[users[0].id,classes[4].id]);}
 await db.query("UPDATE iam.security_clearances SET valid_to=clock_timestamp()-interval '1 second' WHERE user_id=$1 AND classification_id=$2",[users[1].id,classes[4].id]);
 try{assert.equal((await execute(aid)).statusCode,403,'checker authority expired');}finally{await db.query('UPDATE iam.security_clearances SET valid_to=NULL WHERE user_id=$1 AND classification_id=$2',[users[1].id,classes[4].id]);}
 await db.query('UPDATE iam.security_policy_state SET version=version+1 WHERE id');
 assert.equal((await execute(aid)).statusCode,403,'approval policy version stale');
 const freshApproval=await request();
 await db.query('INSERT INTO iam.security_clearances VALUES($1,$2,$3,$4,$5)',[target,classification_id,time,new Date(Date.now()+3600000).toISOString(),users[0].id]);
 assert.equal((await execute(freshApproval)).statusCode,403,'old clearance changed after request');
 assert.equal((await db.query('SELECT state FROM iam.approvals WHERE id=$1',[freshApproval])).rows[0].state,'PENDING');
 await db.query('DELETE FROM iam.security_clearances WHERE user_id=$1 AND classification_id=$2',[target,classification_id]);
 const concurrentApproval=await request();const outcomes=await Promise.all([execute(concurrentApproval),execute(concurrentApproval)]);
 assert.deepEqual(outcomes.map(r=>r.statusCode).sort(),[200,403],'concurrent attempts consume approval once');
 assert.equal((await db.query('SELECT state FROM iam.approvals WHERE id=$1',[concurrentApproval])).rows[0].state,'CONSUMED');
});
