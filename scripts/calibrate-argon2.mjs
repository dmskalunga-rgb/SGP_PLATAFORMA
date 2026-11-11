import { PasswordService } from '../apps/api/dist/password.js';
import { randomBytes } from 'node:crypto';
import { performance } from 'node:perf_hooks';
import { cpus, totalmem, platform, arch } from 'node:os';
import { writeFile, mkdir } from 'node:fs/promises';
const service = await PasswordService.create();
const value = randomBytes(32).toString('base64url');
const measurements = [];
for (let i=0; i<7; i++) {
  const start=performance.now(); const hash=await service.hash(value); const hash_ms=performance.now()-start;
  const verifyStart=performance.now(); if(!await service.verify(hash,value)) throw new Error('Verification failed');
  measurements.push({hash_ms,verify_ms:performance.now()-verifyStart});
}
const sorted=measurements.map(x=>x.hash_ms).sort((a,b)=>a-b);
const result={algorithm:'Argon2id',version:19,...service.policy,hash_length_bytes:32,salt_length_bytes:16,measurements,hash_median_ms:sorted[3],hash_max_ms:sorted.at(-1),node:process.version,platform:platform(),architecture:arch(),CPU:cpus()[0]?.model,logical_CPUs:cpus().length,total_memory_bytes:totalmem(),measured_at_UTC:new Date().toISOString(),decision:'Keep frozen baseline; bounded concurrency=2, no silent weakening; validate institutional target hardware before production'};
await mkdir('artifacts',{recursive:true});
await writeFile('artifacts/argon2-calibration.json',JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result));
