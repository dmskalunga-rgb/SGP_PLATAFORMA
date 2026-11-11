import test from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import { PasswordService, baselinePasswordPolicy, validatePasswordPolicy, HashCapacityError } from '../../apps/api/dist/password.js';
test('Argon2id salts, PHC metadata, verification, NFC and bounded capacity',async()=>{
  const service=await PasswordService.create({...baselinePasswordPolicy,concurrency:1});const value=randomBytes(24).toString('base64url');
  const a=await service.hash(value),b=await service.hash(value);assert.notEqual(a,b);assert.match(a,/^\$argon2id\$v=19\$m=65536,t=3,p=1\$/);
  assert.equal(await service.verify(a,value),true);assert.equal(await service.verify(a,value+'x'),false);assert.equal(service.needsRehash(a),false);
  assert.equal(service.acceptable('short'),false);assert.equal(service.acceptable('123456789012345'),false);assert.equal(service.acceptable('x'.repeat(129)),false);
  assert.equal(service.normalize('e\u0301'.repeat(16)),service.normalize('é'.repeat(16)));
  const running=service.hash(value);await assert.rejects(service.hash(value),HashCapacityError);await running;
  assert.throws(()=>validatePasswordPolicy({...baselinePasswordPolicy,memoryCost:1024}));
});
