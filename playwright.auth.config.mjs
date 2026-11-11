import { defineConfig } from '@playwright/test';
import { resolve } from 'node:path';
export default defineConfig({
 testDir:'tests/auth-browser',workers:1,retries:0,timeout:30000,
 reporter:[['list'],['json',{outputFile:'.test-secrets/auth-browser-results.json'}]],
 globalTeardown:'./scripts/cleanup-auth-browser.mjs',
 use:{baseURL:'https://127.0.0.1:4175',browserName:'chromium',ignoreHTTPSErrors:true,launchOptions:process.env.BROWSER_PATH?{executablePath:process.env.BROWSER_PATH}:{}},
 webServer:[
  {command:'node scripts/auth-browser-api.mjs',url:'http://127.0.0.1:3101/health/live',reuseExistingServer:false},
  {command:'npm run preview -w @sgp/web -- --port 4175 --strictPort',url:'https://127.0.0.1:4175',ignoreHTTPSErrors:true,reuseExistingServer:false,env:{API_UPSTREAM:'http://127.0.0.1:3101',WEB_TLS_CERT_FILE:resolve('.test-secrets/test-tls.crt'),WEB_TLS_KEY_FILE:resolve('.test-secrets/test-tls.key')}}
 ]
});
