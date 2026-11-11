import { readdir, readFile } from 'node:fs/promises';
import { join } from 'node:path';
const excluded=new Set(['node_modules','.git','dist','artifacts','playwright-report','test-results','.test-secrets','.tools']);
const prohibited=/mockData|fakeData|dummyData|sampleData|demoData|fakeDashboard|hardcodedUsers|hardcodedAssets|hardcodedDepartments|Math\.random|TODO button|alert\(["']Em breve|placeholder submit/g;
let findings=0,files=0,mentions=0;
async function scan(dir='.') {
  for (const item of await readdir(dir,{withFileTypes:true})) {
    if (excluded.has(item.name)) continue;
    const path=join(dir,item.name);
    if(item.isDirectory()) await scan(path);
    else if(/\.(ts|tsx|js|mjs|json|md|sql|ya?ml|txt)$/.test(path)) {
      files++;const text=await readFile(path,'utf8');const matches=[...text.matchAll(prohibited)];
      if(matches.length) {
        const operational=/^(apps|packages)[\\/]/.test(path);
        console.log(`${operational?'FAIL operational':'REFERENCE / TEST / SCANNER'} ${path}: ${matches.map(m=>m[0]).join(', ')}`);
        if(operational)findings+=matches.length;else mentions+=matches.length;
      }
    }
  }
}
await scan(); console.log(JSON.stringify({files,operationalFindings:findings,nonOperationalReferences:mentions}));
if(findings)process.exitCode=1;
