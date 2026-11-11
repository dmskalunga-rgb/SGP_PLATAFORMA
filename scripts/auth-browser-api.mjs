import { readFile } from 'node:fs/promises';
import { createApp } from '../apps/api/dist/app.js';
import { baselinePasswordPolicy } from '../apps/api/dist/password.js';
if(process.env.NODE_ENV!=='test')throw new Error('TEST only');
const fixture=JSON.parse(await readFile('.test-secrets/auth-browser.json','utf8'));
const app=await createApp({databaseUrl:fixture.connections.runtime,host:'127.0.0.1',port:3101,logging:false,trustedProxyIPs:['127.0.0.1'],auth:{databaseUrl:fixture.connections.auth,origin:'https://127.0.0.1:4175',passwordPolicy:baselinePasswordPolicy}});
await app.listen({host:'127.0.0.1',port:3101});
for(const signal of ['SIGINT','SIGTERM'])process.on(signal,async()=>{await app.close();process.exit(0);});
