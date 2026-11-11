import { defineConfig } from '@playwright/test';
export default defineConfig({
  testDir:'tests/frontend', retries:0, workers:1, timeout:30000,
  reporter:[['list'],['json',{outputFile:'artifacts/frontend-results.json'}]],
  use:{baseURL:'http://127.0.0.1:4173',browserName:'chromium',launchOptions:process.env.BROWSER_PATH?{executablePath:process.env.BROWSER_PATH}:{}},
  webServer:[
    {command:'node apps/api/dist/index.js',url:'http://127.0.0.1:3100/health/live',env:{PORT:'3100',HOST:'127.0.0.1',LOG_LEVEL:'silent'},reuseExistingServer:false},
    {command:'npm run preview -w @sgp/web -- --port 4173 --strictPort',url:'http://127.0.0.1:4173',env:{API_UPSTREAM:'http://127.0.0.1:3100'},reuseExistingServer:false},
    {command:'npm run preview -w @sgp/web -- --port 4174 --strictPort',url:'http://127.0.0.1:4174',env:{API_UPSTREAM:'http://127.0.0.1:1'},reuseExistingServer:false},
  ],
});
