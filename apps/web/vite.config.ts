import { defineConfig } from 'vite';
import { readFileSync } from 'node:fs';

const upstream = process.env.API_UPSTREAM || 'http://127.0.0.1:3000';
const tls=process.env.WEB_TLS_CERT_FILE&&process.env.WEB_TLS_KEY_FILE?{cert:readFileSync(process.env.WEB_TLS_CERT_FILE),key:readFileSync(process.env.WEB_TLS_KEY_FILE)}:undefined;
const proxy={'/health':upstream,'/api':{target:upstream,headers:{'x-forwarded-proto':tls?'https':'http'},configure(proxyServer: {on:(event:string,handler:(request:{removeHeader:(name:string)=>void;setHeader:(name:string,value:string)=>void})=>void)=>void}){proxyServer.on('proxyReq',request=>{request.removeHeader('forwarded');request.removeHeader('x-forwarded-for');request.setHeader('x-forwarded-proto',tls?'https':'http');});}}};
export default defineConfig({
  server: { host: '127.0.0.1', proxy, https:tls },
  preview: { host: '127.0.0.1', proxy, https:tls },
});
