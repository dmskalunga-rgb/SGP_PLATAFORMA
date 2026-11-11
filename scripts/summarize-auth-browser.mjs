import { readFile,writeFile } from 'node:fs/promises';
const raw=JSON.parse(await readFile('.test-secrets/auth-browser-results.json','utf8'));
const tests=[];
const walk=suite=>{
 for(const spec of suite.specs||[])for(const t of spec.tests||[])tests.push({title:spec.title,status:t.status,results:t.results.map(r=>({status:r.status,duration:r.duration}))});
 for(const child of suite.suites||[])walk(child);
};
for(const suite of raw.suites||[])walk(suite);
await writeFile('artifacts/auth-browser-results.json',JSON.stringify({stats:raw.stats,tests},null,2)+'\n');
if(raw.stats.unexpected||raw.stats.skipped||raw.stats.flaky||raw.stats.expected!==4)process.exitCode=1;
console.log(JSON.stringify({browser_auth_tests:raw.stats.expected,failed:raw.stats.unexpected,skipped:raw.stats.skipped,flaky:raw.stats.flaky}));
