// Local convenience only. The CI uses its existing masked environment variables.
import {readFile} from 'node:fs/promises';
import {spawnSync} from 'node:child_process';
const config=JSON.parse((await readFile('.test-secrets/m1c-db.json','utf8')).replace(/^\uFEFF/,''));
process.env.NODE_ENV='test';process.env.DATABASE_URL=config.owner;process.env.APP_DATABASE_URL=config.runtime;process.env.AUTH_DATABASE_URL=config.auth;
const pg=await import('pg');const root=new pg.default.Client({connectionString:config.owner});await root.connect();
const roles=(await root.query("SELECT count(*)::int AS n FROM pg_roles WHERE rolname IN('app_runtime','auth_runtime')")).rows[0].n;await root.end();
if(roles<2){const {migrate}=await import('./migrate.mjs');await migrate(config.owner);}
await import('./provision-auth-test.mjs');
const args=process.argv.slice(2);
const result=spawnSync(process.execPath,args.length?args:['--test','--test-concurrency=1','tests/integration/authorization.test.mjs'],{env:process.env,stdio:'inherit'});
process.exitCode=result.status??1;
