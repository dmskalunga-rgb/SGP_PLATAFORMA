import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp,mkdir,copyFile,readFile,appendFile,rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join,dirname } from 'node:path';
import { spawnSync } from 'node:child_process';
test('frozen guard accepts exact copy and rejects tampering without modifying project contracts',async()=>{
 const dir=await mkdtemp(join(tmpdir(),'sgp-frozen-test-'));
 try {
  const manifest=JSON.parse(await readFile('EVIDENCE/M1/M1A/FREEZE-MANIFEST.json','utf8'));
  for(const path of ['scripts/check-frozen.mjs','SGP-DISPO-MASTER-v1.0-FROZEN.md','EVIDENCE/M1/M1A/FREEZE-MANIFEST.json',...manifest.files.map(f=>f.path)]){await mkdir(dirname(join(dir,path)),{recursive:true});await copyFile(path,join(dir,path));}
  const invoke=()=>spawnSync(process.execPath,[join(dir,'scripts/check-frozen.mjs')],{encoding:'utf8'});
  assert.equal(invoke().status,0);
  await appendFile(join(dir,manifest.files[0].path),'\nTEST alteration in isolated copy only\n');assert.notEqual(invoke().status,0);
 } finally {await rm(dir,{recursive:true,force:true});}
});
