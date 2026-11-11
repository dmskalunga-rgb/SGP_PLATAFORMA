import test from 'node:test';
import assert from 'node:assert/strict';
import { readConfig } from '../../apps/api/dist/config.js';
test('configuration fails closed on absent, malformed or non-PostgreSQL connection', () => {
  for (const DATABASE_URL of [undefined, 'bad-url', 'file:///db']) assert.throws(() => readConfig({DATABASE_URL}));
});
test('configuration rejects invalid ports and environment', () => {
  const DATABASE_URL='postgresql://localhost/sgp_test';
  for (const PORT of ['0','65536','1.2','abc']) assert.throws(() => readConfig({DATABASE_URL,PORT}));
  assert.throws(() => readConfig({DATABASE_URL,NODE_ENV:'demo'}));
  assert.equal(readConfig({DATABASE_URL,NODE_ENV:'test'}).host,'127.0.0.1');
});
