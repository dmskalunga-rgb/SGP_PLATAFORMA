import {test,expect} from '@playwright/test';
import {readFile} from 'node:fs/promises';
import {randomBytes,randomUUID} from 'node:crypto';
import pg from 'pg';
const fixture=JSON.parse(await readFile('.test-secrets/auth-browser.json','utf8'));
const origin='https://127.0.0.1:4175';
test.use({actionTimeout:10000});
async function login(page,person){await page.goto('/login');await page.getByLabel('Utilizador',{exact:true}).fill(person.username);await page.getByLabel('Palavra-passe',{exact:true}).fill(person.password);await page.getByRole('button',{name:'Entrar',exact:true}).click();await expect(page).toHaveURL(/\/profile$/);}
async function form(page,label){const d=page.locator('details').filter({has:page.locator('summary').filter({hasText:new RegExp('^'+label+'$')})});await d.locator('summary').click();return d.locator('form').first();}
async function submit(page,f,label){await f.getByRole('button',{name:label,exact:true}).click();await expect(page.getByRole('status').filter({hasText:'Operação concluída'})).toBeVisible();await expect(page.getByRole('status').filter({hasText:'A carregar'})).toHaveCount(0);}

test('M1D governed browser administration, approval inbox, new-user access, entitlement/session revocation and audit',async({browser})=>{
 test.setTimeout(120000);
 const contexts=await Promise.all([0,1,2].map(()=>browser.newContext({ignoreHTTPSErrors:true})));
 const [admin,checker,user]=await Promise.all(contexts.map(c=>c.newPage()));const errors=[];for(const p of [admin,checker,user])p.on('pageerror',e=>errors.push(e.message));
 const person={username:'test_m1d_'+randomUUID().slice(0,8),password:randomBytes(24).toString('base64url'),display_name:'TEST browser M1D user'};
 try{
  const db=new pg.Client({connectionString:fixture.connections.owner});await db.connect();let classification,permission,compartment;
  try{await db.query('TRUNCATE iam.rate_buckets,iam.preauth_nonces');classification=(await db.query('SELECT id FROM iam.security_classifications ORDER BY rank LIMIT 1')).rows[0].id;permission=(await db.query("SELECT id FROM iam.permissions WHERE code='security.roles.read'")).rows[0].id;compartment=(await db.query("INSERT INTO iam.security_compartments(code,sensitive) VALUES($1,false) RETURNING id",['TEST_BROWSER_'+randomUUID().slice(0,8)])).rows[0].id;for(const p of fixture.people)await db.query('INSERT INTO iam.user_compartments(user_id,compartment_id,authority) VALUES($1,$2,$1)',[p.id,compartment]);}finally{await db.end();}
  await login(admin,fixture.people[0]);await admin.goto('/security/users');await expect(admin.getByRole('heading',{name:'Administração de segurança'})).toBeVisible();
  let f=await form(admin,'Criar identidade');await f.getByLabel('Utilizador',{exact:true}).fill(person.username);await f.getByLabel('Nome',{exact:true}).fill(person.display_name);await f.getByLabel('Palavra-passe inicial').fill(person.password);await f.getByLabel('Âmbito',{exact:true}).selectOption('IAM_GLOBAL');await f.getByLabel('Classificação da identidade').fill(classification);await submit(admin,f,'Criar identidade');
  let users=await(await admin.request.get(origin+'/api/v1/security/users?limit=100')).json();const target=users.items.find(x=>x.username===person.username).id;
  f=await form(admin,'Alterar estado da conta / revogar sessões');await f.getByLabel('Utilizador alvo').fill(target);await f.getByLabel('Operação',{exact:true}).selectOption('ACTIVE');await submit(admin,f,'Alterar estado da conta / revogar sessões');
  f=await form(admin,'Criar função');await f.getByLabel('Código',{exact:true}).fill('TEST_BROWSER_READER');await f.getByLabel('Âmbito',{exact:true}).selectOption('IAM_GLOBAL');await f.getByLabel('Classificação',{exact:true}).fill(classification);await submit(admin,f,'Criar função');
  const roles=await(await admin.request.get(origin+'/api/v1/security/roles?limit=100')).json();const rid=roles.items.find(x=>x.code==='TEST_BROWSER_READER').id;
  f=await form(admin,'Permissão da função');await f.getByLabel('Função',{exact:true}).fill(rid);await f.getByLabel('Permissão',{exact:true}).fill(permission);await submit(admin,f,'Permissão da função');
  f=await form(admin,'Atribuir / agendar função');await f.getByLabel('Utilizador',{exact:true}).fill(target);await f.getByLabel('Função',{exact:true}).fill(rid);await f.getByLabel('Âmbito',{exact:true}).selectOption('IAM_GLOBAL');await f.getByLabel('Início (hora local)').fill('2026-01-01T00:00');await submit(admin,f,'Atribuir / agendar função');
  f=await form(admin,'Conceder compartimento');await f.getByLabel('Utilizador',{exact:true}).fill(target);await f.getByLabel('Compartimento',{exact:true}).fill(compartment);await f.getByLabel('Início (hora local)').fill('2026-01-01T00:00');await submit(admin,f,'Conceder compartimento');
  f=await form(admin,'Pedir alteração privilegiada');await f.getByLabel('Utilizador',{exact:true}).fill(target);await f.getByLabel('Classificação',{exact:true}).fill(classification);await f.getByLabel('Início (hora local)').fill('2026-01-01T00:00');await f.getByRole('button',{name:'Pedir aprovação'}).click();await expect(admin.getByRole('status').filter({hasText:'Operação concluída'})).toBeVisible();
  await admin.getByRole('button',{name:'Aprovações',exact:true}).click();let row=admin.locator('tr').filter({hasText:target});await expect(row).toHaveCount(1);await row.getByRole('button',{name:'Aprovar',exact:true}).click();await expect(admin.getByRole('alert')).toContainText('não autorizada');
  await login(checker,fixture.people[1]);await checker.goto('/security/approvals');row=checker.locator('tr').filter({hasText:target});await expect(row).toHaveCount(1);await row.getByRole('button',{name:'Aprovar',exact:true}).click();await expect(checker.getByRole('status').filter({hasText:'Operação concluída'})).toBeVisible();await expect(checker.getByRole('button',{name:'Aprovar',exact:true})).toHaveCount(0);
  await login(user,person);await user.goto('/security/roles');await expect(user.getByRole('cell',{name:'TEST_BROWSER_READER',exact:true})).toBeVisible();expect((await user.request.get(origin+'/api/v1/security/users')).status()).toBe(403);
  await admin.getByRole('button',{name:'Atribuições',exact:true}).click();await admin.getByLabel('Filtrar por utilizador').fill(target);const assignments=await(await admin.request.get(origin+'/api/v1/security/administration/assignments?subject_id='+target)).json();
  f=await form(admin,'Revogar atribuição');await f.getByLabel('Atribuição',{exact:true}).fill(assignments.items[0].id);await submit(admin,f,'Revogar atribuição');await user.reload();await expect(user.getByRole('alert')).toContainText('não autorizada');
  f=await form(admin,'Revogar sessões');await f.getByLabel('Utilizador alvo').fill(target);await f.getByLabel('Operação',{exact:true}).selectOption('REVOKE_ALL');await submit(admin,f,'Revogar sessões');expect((await user.request.get(origin+'/api/v1/auth/session')).status()).toBe(401);
  await admin.getByRole('button',{name:'Auditoria',exact:true}).click();await admin.getByLabel('target',{exact:true}).fill(target);await admin.getByRole('button',{name:'Filtrar auditoria'}).click();await expect(admin.locator('tbody tr').first()).toBeVisible();await admin.screenshot({path:'artifacts/m1d-admin-ui.png'});expect(errors).toEqual([]);
 }finally{await Promise.allSettled(contexts.map(context=>context.close()));}
});
