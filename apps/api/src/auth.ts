import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import pg from 'pg';
import { createHash, randomBytes, randomUUID, timingSafeEqual } from 'node:crypto';
import { PasswordService, HashCapacityError, type PasswordPolicy } from './password.js';
import { PostgreSQLAuthorization } from './authorization.js';

export type AuthConfig = { databaseUrl: string; origin: string; passwordPolicy: PasswordPolicy; poolSize?: number };
declare module 'fastify' { interface FastifyRequest { auth: Readonly<Record<string, unknown>> | null } }
class AuthError extends Error { constructor(readonly statusCode: number, readonly publicCode: string) { super(publicCode); } }
const token = () => randomBytes(32).toString('base64url');
export const csrfFor = (value: string, domain = 'session') => createHash('sha256').update(domain+':'+value).digest('base64url');
const validToken = (value: string) => /^[A-Za-z0-9_-]{43}$/.test(value);
function cookieValue(request: FastifyRequest, name: string) {
  const values=(request.headers.cookie || '').split(';').map(s=>s.trim()).filter(s=>s.startsWith(name+'='));
  if(values.length!==1) return '';
  const value=values[0].slice(name.length+1);return validToken(value)?value:'';
}
function setCookie(reply: FastifyReply, name: string, value: string, lifetime: number) { reply.header('Set-Cookie',`${name}=${value}; Path=/; Max-Age=${lifetime}; HttpOnly; Secure; SameSite=Strict`); }
function freezeDeep<T>(object: T): T {
  if(object && typeof object==='object') { for(const value of Object.values(object)) freezeDeep(value); Object.freeze(object); }
  return object;
}
const string = { type:'string' };
const body = (properties: Record<string,unknown>, required = Object.keys(properties)) => ({ type:'object', additionalProperties:false, properties, required });
const username = {type:'string',pattern:'^[a-z0-9._-]{3,64}$',maxLength:64};
const password = {type:'string',minLength:1,maxLength:128};
const errorSchema=body({error:string,request_id:string});
const errors={400:errorSchema,401:errorSchema,403:errorSchema,404:errorSchema,429:errorSchema,503:errorSchema};
const sessionSchema=body({user:body({id:string,username:string,display_name:string}),session:body({created_at:string,expires_at:string,idle_expires_at:string,authentication_strength:string}),csrf_token:string});

export async function registerAuth(app: FastifyInstance, appPool: pg.Pool, config: AuthConfig) {
  const passwords=await PasswordService.create(config.passwordPolicy);
  const authPool=new pg.Pool({connectionString:config.databaseUrl,connectionTimeoutMillis:2000,max:config.poolSize||5});
  for(const [pool,expected] of [[appPool,'app_runtime'],[authPool,'auth_runtime']] as const) {
    const identity=(await pool.query('SELECT current_user AS name,rolsuper,rolcreaterole,rolcreatedb,rolbypassrls FROM pg_roles WHERE rolname=current_user')).rows[0];
    if(identity.name!==expected || identity.rolsuper || identity.rolcreaterole || identity.rolcreatedb || identity.rolbypassrls) {await authPool.end();throw new Error('Authentication database privilege boundary invalid');}
  }
  authPool.on('error',()=>app.log.error({event:'auth_database_pool_error'},'Authentication authority unavailable'));
  app.addHook('onClose',async()=>authPool.end());
  app.decorateRequest('auth',null);
  const meta=(request:FastifyRequest) => [request.ip,request.id,request.id];
  function transport(request:FastifyRequest,mutation:boolean) {
    if(request.protocol!=='https') throw new AuthError(403,'secure_transport_required');
    if(mutation && request.headers.origin!==config.origin) throw new AuthError(403,'invalid_origin');
  }
  function csrf(request:FastifyRequest, raw:string, domain='session') {
    const supplied=request.headers['x-csrf-token'];
    const expected=csrfFor(raw,domain);
    if(typeof supplied!=='string' || !validToken(supplied) || !timingSafeEqual(Buffer.from(supplied),Buffer.from(expected))) throw new AuthError(403,'invalid_csrf');
    return supplied;
  }
  async function transaction<T>(pool:pg.Pool,run:(client:pg.PoolClient)=>Promise<T>):Promise<T> {
    const client=await pool.connect();let destroyed=false;
    const timer=setTimeout(()=>{destroyed=true;client.release(true);},15000);
    try {
      await client.query('BEGIN');
      await client.query("SET LOCAL statement_timeout='5s'; SET LOCAL lock_timeout='2s'; SET LOCAL idle_in_transaction_session_timeout='5s'; SET LOCAL transaction_timeout='15s'");
      const result=await run(client);await client.query('COMMIT');return result;
    } catch(error) { if(!destroyed) try {await client.query('ROLLBACK');} catch {destroyed=true;client.release(true);} throw error; }
    finally {clearTimeout(timer);if(!destroyed)client.release();}
  }
  async function command(pool:pg.Pool,sql:string,args:unknown[]) { return transaction(pool,async client=>(await client.query(sql,args)).rows); }
  const safe = (run:(req:FastifyRequest,reply:FastifyReply)=>Promise<unknown>) => async(req:FastifyRequest,reply:FastifyReply) => {
    try {return await run(req,reply);} catch(error) {
      const status=error instanceof AuthError?error.statusCode:error instanceof HashCapacityError?429:503;
      req.log.warn({event:'authentication_request_failed',request_id:req.id,correlation_id:req.id,status},'Authentication request failed');
      return reply.status(status).send({error:error instanceof AuthError?error.publicCode:status===429?'try_later':'authority_unavailable',request_id:req.id});
    }
  };
  app.get('/api/v1/auth/csrf',{schema:{response:{200:body({csrf_token:string}),...errors}}},safe(async(req,reply)=>{
    transport(req,false);const raw=token(),csrfToken=csrfFor(raw,'preauth');
    const rows=await command(authPool,'SELECT iam.preauth($1,$2,$3,$4) AS ok',[raw,csrfToken,config.origin,req.ip]);
    if(!rows[0].ok)throw new AuthError(429,'try_later');
    setCookie(reply,'__Host-sgp_preauth',raw,300);return {csrf_token:csrfToken};
  }));
  app.post('/api/v1/auth/login',{bodyLimit:2048,schema:{body:body({username,password}),response:{200:body({authenticated:{type:'boolean'}}),...errors}}},safe(async(req,reply)=>{
    transport(req,true);const input=req.body as {username:string;password:string};
    const preauth=cookieValue(req,'__Host-sgp_preauth');const preCsrf=csrf(req,preauth,'preauth');
    const nonce=await command(authPool,'SELECT iam.consume_nonce($1,$2,$3,$4,$5,$6) AS result',[preauth,preCsrf,config.origin,...meta(req)]);
    if(nonce[0].result!=='OK')throw new AuthError(nonce[0].result==='RATE_LIMIT'?429:403,nonce[0].result==='RATE_LIMIT'?'try_later':'invalid_csrf');
    const credential=(await command(authPool,'SELECT * FROM iam.credential_lookup($1)',[input.username]))[0];
    const verified=await passwords.verify(credential?.password_hash,input.password);
    const replacement=verified&&credential&&passwords.needsRehash(credential.password_hash)?await passwords.hash(input.password):null;
    const raw=token();const result=await command(authPool,'SELECT iam.login_result($1,$2,$3,$4,$5,$6,$7,$8,$9) AS ok',[input.username,Boolean(verified&&credential),credential?.credential_version??null,replacement,raw,csrfFor(raw),...meta(req)]);
    if(!result[0].ok)throw new AuthError(401,'authentication_failed');
    setCookie(reply,'__Host-sgp_session',raw,28800);return {authenticated:true};
  }));
  app.get('/api/v1/auth/session',{schema:{response:{200:sessionSchema,...errors}}},safe(async(req)=>{
    transport(req,false);const raw=cookieValue(req,'__Host-sgp_session');
    if(!raw)throw new AuthError(401,'session_invalid');
    const ctx=await transaction(appPool,async client=>{
      const result=(await client.query('SELECT iam.bind_request($1,false,$2,$3,$4) AS context',[raw,...meta(req)])).rows[0].context;
      if(result) {
        const verified=(await client.query('SELECT iam.bound_context() AS context')).rows[0].context;
        if(!verified)throw new Error('Context verification failed');
        req.auth=freezeDeep(verified);
      }
      await client.query('SELECT iam.finish_request()');return result;
    });
    if(!ctx)throw new AuthError(401,'session_invalid');
    return {user:{id:ctx.user_id,username:ctx.username,display_name:ctx.display_name},session:{created_at:ctx.session_created_at,expires_at:ctx.session_expires_at,idle_expires_at:ctx.idle_expires_at,authentication_strength:ctx.authentication_strength},csrf_token:csrfFor(raw)};
  }));
  app.post('/api/v1/auth/logout',{schema:{body:body({}),response:{204:{type:'null'},...errors}}},safe(async(req,reply)=>{
    transport(req,true);const raw=cookieValue(req,'__Host-sgp_session');
    if(raw) {
      const proof=csrf(req,raw);const result=await command(authPool,'SELECT iam.logout($1,$2,$3,$4,$5) AS ok',[raw,proof,...meta(req)]);
      if(!result[0].ok)throw new AuthError(403,'invalid_csrf');
    }
    setCookie(reply,'__Host-sgp_session','',0);return reply.status(204).send();
  }));
  app.post('/api/v1/auth/rotate',{schema:{body:body({}),response:{200:body({csrf_token:string}),...errors}}},safe(async(req,reply)=>{
    transport(req,true);const old=cookieValue(req,'__Host-sgp_session');const proof=csrf(req,old),fresh=token();
    const result=await command(authPool,'SELECT iam.rotate_session($1,$2,$3,$4,$5,$6,$7) AS ok',[old,proof,fresh,csrfFor(fresh),...meta(req)]);
    if(!result[0].ok)throw new AuthError(401,'session_invalid');
    setCookie(reply,'__Host-sgp_session',fresh,28800);return {csrf_token:csrfFor(fresh)};
  }));
  app.post('/api/v1/auth/change-password',{bodyLimit:2048,schema:{body:body({current_password:password,new_password:{...password,minLength:15}}),response:{204:{type:'null'},...errors}}},safe(async(req,reply)=>{
    transport(req,true);const raw=cookieValue(req,'__Host-sgp_session'),proof=csrf(req,raw),input=req.body as {current_password:string;new_password:string};
    if(!passwords.acceptable(input.new_password))throw new AuthError(400,'password_policy');
    const c=(await command(authPool,'SELECT * FROM iam.credential_for_session($1,$2,$3,$4)',[raw,...meta(req)]))[0];
    if(!c)throw new AuthError(401,'session_invalid');
    const verified=await passwords.verify(c.password_hash,input.current_password);
    if(!verified || await passwords.verify(c.password_hash,input.new_password))throw new AuthError(400,'password_change_rejected');
    const hash=await passwords.hash(input.new_password);
    const result=await command(authPool,'SELECT iam.change_password($1,$2,$3,$4,$5,$6,$7,$8) AS ok',[raw,proof,verified,c.credential_version,hash,...meta(req)]);
    if(!result[0].ok)throw new AuthError(401,'session_invalid');
    setCookie(reply,'__Host-sgp_session','',0);return reply.status(204).send();
  }));
  app.post('/api/v1/auth/admin/account-command',{schema:{body:body({target_id:{type:'string',format:'uuid'},action:{type:'string',enum:['REVOKE_ONE','REVOKE_ALL','ACTIVE','INACTIVE','LOCKED','DISABLED']},session_id:{type:'string',format:'uuid'}},['target_id','action']),response:{204:{type:'null'},...errors}}},safe(async(req,reply)=>{
    transport(req,true);const raw=cookieValue(req,'__Host-sgp_session'),proof=csrf(req,raw),input=req.body as {target_id:string;action:string;session_id?:string};
    if(input.action==='REVOKE_ONE'&&!input.session_id)throw new AuthError(400,'invalid_request');
    const result=await command(appPool,'SELECT iam.account_command($1,$2,$3,$4,$5,$6,$7,$8) AS ok',[raw,proof,input.target_id,input.action,input.session_id??null,...meta(req)]);
    if(!result[0].ok)throw new AuthError(403,'access_denied');
    return reply.status(204).send();
  }));

  // Minimal M1C proof surface. The complete IAM administration UI is M1D.
  const uuid={type:'string',format:'uuid'},nullableUuid={anyOf:[uuid,{type:'null'}]};
  const timestamp={type:'string',format:'date-time'},nullableTime={anyOf:[timestamp,{type:'null'}]};
  const scoped={scope_kind:{type:'string',enum:['IAM_GLOBAL','SCOPED']},scope_id:nullableUuid};
  const period={valid_from:timestamp,valid_to:nullableTime};
  async function bound<T>(req:FastifyRequest,run:(client:pg.PoolClient,ctx:Readonly<Record<string,unknown>>)=>Promise<T>) {
    transport(req,false);const raw=cookieValue(req,'__Host-sgp_session');if(!raw)throw new AuthError(401,'session_invalid');
    return transaction(appPool,async client=>{
      const ctx=(await client.query('SELECT iam.bind_request($1,false,$2,$3,$4) AS context',[raw,...meta(req)])).rows[0].context;
      if(!ctx)throw new AuthError(401,'session_invalid');req.auth=freezeDeep(ctx);
      const value=await run(client,req.auth!);await client.query('SELECT iam.finish_request()');return value;
    });
  }
  app.get('/api/v1/security/capabilities',{schema:{response:{200:body({actions:{type:'array',items:string}}),...errors}}},safe(async req=>bound(req,async client=>({actions:(await client.query('SELECT iam.capabilities() AS actions')).rows[0].actions}))));
  const lists=[['users','security.users.read','IAM_IDENTITY'],['roles','security.roles.read','IAM_ROLE'],['permissions','security.permissions.read','IAM_PERMISSION']] as const;
  for(const [path,permission,list,count] of [
    ['audit','security.audit.read','SELECT id,actor_id,target_id,action,occurred_at,result,session_id,request_id,correlation_id,policy_version,decision_id,before_state,after_state FROM iam.authorization_events ORDER BY occurred_at DESC,id LIMIT $1 OFFSET $2','SELECT count(*)::int AS total FROM iam.authorization_events'],
    ['sessions','security.sessions.read','SELECT id,user_id,created_at,expires_at,idle_expires_at,revoked_at,authentication_strength FROM iam.sessions ORDER BY id LIMIT $1 OFFSET $2','SELECT count(*)::int AS total FROM iam.sessions'],
  ])app.get('/api/v1/security/'+path,{schema:{querystring:{type:'object',additionalProperties:false,properties:{limit:{type:'string',pattern:'^[1-9][0-9]?$|^100$'},offset:{type:'string',pattern:'^[0-9]{1,6}$'}}}}},safe(async req=>bound(req,async client=>{
    const actions=(await client.query('SELECT iam.capabilities() AS actions')).rows[0].actions as string[];if(!actions.includes(permission))throw new AuthError(403,'access_denied');
    const q=req.query as {limit?:string;offset?:string};return {items:(await client.query(list,[Number(q.limit??25),Number(q.offset??0)])).rows,total:(await client.query(count)).rows[0].total};
  })));
  const queries={
    users:{list:'SELECT id,username,display_name,status FROM iam.users ORDER BY id LIMIT $1 OFFSET $2',count:'SELECT count(*)::int AS total FROM iam.users',one:'SELECT id,username,display_name,status FROM iam.users WHERE id=$1'},
    roles:{list:'SELECT id,code,status,version FROM iam.roles ORDER BY id LIMIT $1 OFFSET $2',count:'SELECT count(*)::int AS total FROM iam.roles',one:'SELECT id,code,status,version FROM iam.roles WHERE id=$1'},
    permissions:{list:'SELECT id,code,action,resource_type,status FROM iam.permissions ORDER BY id LIMIT $1 OFFSET $2',count:'SELECT count(*)::int AS total FROM iam.permissions',one:'SELECT id,code,action,resource_type,status FROM iam.permissions WHERE id=$1'},
  };
  for(const [name,permission,type] of lists) {
    app.get('/api/v1/security/'+name,{schema:{querystring:{type:'object',additionalProperties:false,properties:{limit:{type:'string',pattern:'^[1-9][0-9]?$|^100$'},offset:{type:'string',pattern:'^[0-9]{1,6}$'}}}}},safe(async req=>bound(req,async client=>{
      const actions=(await client.query('SELECT iam.capabilities() AS actions')).rows[0].actions as string[];
      if(!actions.includes(permission))throw new AuthError(403,'access_denied');
      const query=req.query as {limit?:string;offset?:string};
      const rows=await client.query(queries[name].list,[Number(query.limit??25),Number(query.offset??0)]);
      const count=await client.query(queries[name].count);
      return {items:rows.rows,total:count.rows[0].total};
    })));
    app.get('/api/v1/security/'+name+'/:id',{schema:{params:body({id:uuid})}},safe(async req=>{
      const row=await bound(req,async(client,ctx)=>{
        const id=(req.params as {id:string}).id;
        // Lookup is already under RLS; hidden and absent objects are identical.
        const found=(await client.query(queries[name].one,[id])).rows[0];
        const decision=await new PostgreSQLAuthorization(client).authorize(String(ctx.user_id),permission,{type,id},ctx);
        return decision.decision==='ALLOW'?found:null;
      });
      // Commit a read-only denial audit before returning the public 404.
      if(!row)throw new AuthError(404,'not_found');return row;
    }));
  }
  const mutations:[string,Record<string,unknown>,string,(input:Record<string,unknown>)=>unknown[]][]=[
    ['roles', {code:{type:'string',pattern:'^[A-Z][A-Z0-9_]{2,63}$'},...scoped,classification_id:uuid,compartments:{type:'array',items:uuid,maxItems:32,uniqueItems:true},privileged:{type:'boolean'}},'SELECT iam.create_role($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11) AS id',v=>[v.code,v.scope_kind,v.scope_id,v.classification_id,v.compartments,v.privileged]],
    ['role-permissions',{role_id:uuid,permission_id:uuid,enabled:{type:'boolean'}},'SELECT iam.set_role_permission($1,$2,$3,$4,$5,$6,$7,$8)',v=>[v.role_id,v.permission_id,v.enabled]],
    ['approvals',{target_id:uuid,operation:{type:'string',enum:['ROLE_GRANT','CLEARANCE_GRANT','COMPARTMENT_GRANT']},payload:{type:'object',maxProperties:5},idempotency_key:uuid},'SELECT iam.request_approval($1,$2,$3,$4,$5,$6,$7,$8,$9) AS id',v=>[v.target_id,v.operation,v.payload,v.idempotency_key]],
    ['assignments',{target_id:uuid,role_id:uuid,...scoped,...period,approval_id:nullableUuid},'SELECT iam.assign_role($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12) AS id',v=>[v.target_id,v.role_id,v.scope_kind,v.scope_id,v.valid_from,v.valid_to,v.approval_id]],
    ['clearances',{target_id:uuid,classification_id:uuid,...period,approval_id:nullableUuid},'SELECT iam.grant_clearance($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',v=>[v.target_id,v.classification_id,v.valid_from,v.valid_to,v.approval_id]],
    ['compartments',{target_id:uuid,compartment_id:uuid,...period,approval_id:nullableUuid},'SELECT iam.grant_compartment($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',v=>[v.target_id,v.compartment_id,v.valid_from,v.valid_to,v.approval_id]],
    ['assignment-revocations',{assignment_id:uuid},'SELECT iam.revoke_assignment($1,$2,$3,$4,$5,$6)',v=>[v.assignment_id]],
  ];
  for(const [path,properties,sql,args] of mutations)app.post('/api/v1/security/'+path,{bodyLimit:8192,schema:{body:body(properties),response:{200:body({completed:{type:'boolean'},id:nullableUuid}),...errors}}},safe(async(req)=>{
    transport(req,true);const raw=cookieValue(req,'__Host-sgp_session');if(!raw)throw new AuthError(401,'session_invalid');const proof=csrf(req,raw);
    try {const rows=await command(appPool,sql,[raw,proof,...args(req.body as Record<string,unknown>),...meta(req)]);return {completed:true,id:rows[0].id??null};}
    catch(error){
      if(error&&typeof error==='object'&&'code' in error&&(error.code==='PT403'||error.code==='PT401')){
        if(error.code==='PT403'){
          const input=req.body as Record<string,unknown>;
          await command(appPool,'SELECT iam.record_rejection($1,$2,$3,$4,$5,$6)',[raw,path,input.target_id??null,...meta(req)]);
        }
        throw new AuthError(error.code==='PT401'?401:403,error.code==='PT401'?'session_invalid':'access_denied');
      }
      throw error;
    }
  }));
}

export const makeRequestId = () => randomUUID();
