import {readFile} from 'node:fs/promises';
const workflow=await readFile('.github/workflows/ci.yml','utf8');
const steps=workflow.split(/^ {6}- /m);
let checked=0;
for(const step of steps){
 if(!/\|\s*tee\b/.test(step))continue;
 checked++;
 if(!/^ {8}shell: bash\s*$/m.test(step)||!/^ {10}set -o pipefail\s*$/m.test(step)||step.indexOf('set -o pipefail')>step.search(/\|\s*tee\b/))throw new Error('Critical tee pipeline requires explicit bash and pipefail before execution');
 if(/continue-on-error:\s*true|\|\|\s*true/.test(step))throw new Error('Critical pipeline must not suppress failure');
}
if(checked!==2)throw new Error('Review changed critical tee pipeline inventory');
console.log(`Critical tee pipelines: ${checked}, explicit fail-closed policy PASS`);
