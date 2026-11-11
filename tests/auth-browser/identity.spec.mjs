import { test,expect } from '@playwright/test';
import { readFile } from 'node:fs/promises';
import pg from 'pg';
const fixture=JSON.parse(await readFile('.test-secrets/auth-browser.json','utf8'));
async function login(page,person){await page.goto('/login');await page.getByLabel('Utilizador',{exact:true}).fill(person.username);await page.getByLabel('Palavra-passe',{exact:true}).fill(person.password);await page.getByRole('button',{name:'Entrar',exact:true}).click();await expect(page).toHaveURL(/\/profile$/);await expect(page.getByRole('heading',{name:'A minha sessão'})).toBeVisible();}
test.beforeEach(async()=>{const db=new pg.Client({connectionString:fixture.connections.owner});await db.connect();try{await db.query('TRUNCATE iam.rate_buckets,iam.preauth_nonces');await db.query("UPDATE iam.users SET status='ACTIVE',lock_kind=NULL,locked_until=NULL,failed_attempts=0,failure_window_start=NULL");}finally{await db.end();}});
test('one-time bootstrap → real TLS browser login → persistent session → logout → replay denied',async({page,context})=>{
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 await login(page,fixture.people[0]);const cookies=await context.cookies();const saved=cookies.find(c=>c.name==='__Host-sgp_session');expect(saved.secure&&saved.httpOnly&&saved.sameSite==='Strict').toBeTruthy();
 const session=await page.request.get('/api/v1/auth/session');expect(session.status()).toBe(200);expect((await session.json()).user.id).toBe(fixture.people[0].id);
 await page.getByRole('link',{name:'Terminar sessão',exact:true}).click();await page.getByRole('button',{name:'Confirmar saída'}).click();await expect(page).toHaveURL(/\/login$/);
 await context.addCookies([saved]);expect((await page.request.get('/api/v1/auth/session')).status()).toBe(401);await page.goto('/profile');await expect(page).toHaveURL(/\/session-expired$/);expect(errors).toEqual([]);
});
test('administrator revokes another real browser session → authenticated retry denied',async({browser})=>{
 const a=await browser.newContext({ignoreHTTPSErrors:true}),b=await browser.newContext({ignoreHTTPSErrors:true});const admin=await a.newPage(),user=await b.newPage();
 try{await login(admin,fixture.people[0]);await login(user,fixture.people[1]);const session=await(await admin.request.get('https://127.0.0.1:4175/api/v1/auth/session')).json();
 const revoke=await admin.request.post('https://127.0.0.1:4175/api/v1/auth/admin/account-command',{headers:{Origin:'https://127.0.0.1:4175','X-CSRF-Token':session.csrf_token},data:{target_id:fixture.people[1].id,action:'REVOKE_ALL'}});expect(revoke.status()).toBe(204);await user.reload();await expect(user).toHaveURL(/\/session-expired$/);
 }finally{await a.close();await b.close();}
});
test('repeated invalid login locks account; valid credential remains denied and audit reconstructs sequence',async({page})=>{
 for(let i=0;i<5;i++){await page.goto('/login');await page.getByLabel('Utilizador',{exact:true}).fill(fixture.people[1].username);await page.getByLabel('Palavra-passe',{exact:true}).fill('TEST-invalid-credential-value');await page.getByRole('button',{name:'Entrar',exact:true}).click();await expect(page.getByRole('alert')).toContainText('Não foi possível autenticar');}
 await page.goto('/login');await page.getByLabel('Utilizador',{exact:true}).fill(fixture.people[1].username);await page.getByLabel('Palavra-passe',{exact:true}).fill(fixture.people[1].password);await page.getByRole('button',{name:'Entrar',exact:true}).click();await expect(page.getByRole('alert')).toContainText('Não foi possível autenticar');
 const db=new pg.Client({connectionString:fixture.connections.owner});await db.connect();try{const result=await db.query('SELECT event FROM iam.authentication_events WHERE target_id=$1 ORDER BY occurred_at',[fixture.people[1].id]);expect(result.rows.filter(r=>r.event==='LOGIN_FAILURE').length).toBeGreaterThanOrEqual(6);expect(result.rows.some(r=>r.event==='ACCOUNT_LOCKED')).toBeTruthy();}finally{await db.end();}
});

test('M1C frontend hides unavailable action while direct API independently denies',async({page})=>{
 await login(page,fixture.people[0]);
 const action=page.getByRole('button',{name:'Consultar funções autorizadas'});await expect(action).toBeVisible();await action.click();await expect(page.getByText('SECURITY_BOOTSTRAP_OPERATOR',{exact:true})).toBeVisible();
 const db=new pg.Client({connectionString:fixture.connections.owner});await db.connect();
 try{
  await db.query("DELETE FROM iam.role_permissions WHERE role_id=(SELECT id FROM iam.roles WHERE code='SECURITY_BOOTSTRAP_OPERATOR') AND permission_id=(SELECT id FROM iam.permissions WHERE code='security.roles.read')");
  await page.reload();await expect(page.getByRole('heading',{name:'A minha sessão'})).toBeVisible();await expect(action).toHaveCount(0);
  expect((await page.request.get('/api/v1/security/roles')).status()).toBe(403);
 }finally{await db.query("INSERT INTO iam.role_permissions SELECT r.id,p.id FROM iam.roles r CROSS JOIN iam.permissions p WHERE r.code='SECURITY_BOOTSTRAP_OPERATOR' AND p.code='security.roles.read' ON CONFLICT DO NOTHING");await db.end();}
});
