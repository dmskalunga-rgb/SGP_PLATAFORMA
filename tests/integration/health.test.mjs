import test from 'node:test';
import assert from 'node:assert/strict';
import { createApp } from '../../apps/api/dist/app.js';
import { migrate } from '../../scripts/migrate.mjs';
import { withSchema } from '../helpers.mjs';
test('real readiness requires migrated schema; live survives missing schema; headers and error disclosure', async () => withSchema(async url => {
  const app=await createApp({databaseUrl:url,host:'127.0.0.1',port:3000,logging:false});
  try {
    assert.equal((await app.inject('/health/live')).statusCode,200);
    assert.equal((await app.inject('/health/ready')).statusCode,503);
    await migrate(url);
    const ready=await app.inject('/health/ready'); assert.equal(ready.statusCode,200); assert.deepEqual(ready.json(),{status:'ok'});
    assert.equal(ready.headers['cache-control'],'no-store'); assert.ok(ready.headers['x-content-type-options']);
    assert.equal(ready.headers['access-control-allow-origin'],undefined);
    assert.equal((await app.inject('/api/v1/users')).statusCode,404);
    const oversized=await app.inject({method:'POST',url:'/health/live',headers:{'content-type':'application/json'},payload:'x'.repeat(1048577)});
    assert.equal(oversized.statusCode,413); assert.equal(oversized.json().error,'invalid_request'); assert.ok(!oversized.body.includes(url));
  } finally { await app.close(); }
}));
test('real network failure returns 503 with sanitised body while liveness remains 200', async () => {
  const failedUrl=new URL(process.env.DATABASE_URL);failedUrl.port='1';
  const app=await createApp({databaseUrl:failedUrl.href,host:'127.0.0.1',port:3000,logging:false});
  try { const r=await app.inject('/health/ready'); assert.equal(r.statusCode,503); assert.deepEqual(r.json(),{status:'unavailable'}); assert.equal((await app.inject('/health/live')).statusCode,200); }
  finally {await app.close();}
});
