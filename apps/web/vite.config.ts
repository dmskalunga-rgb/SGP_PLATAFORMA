import { defineConfig } from 'vite';

const upstream = process.env.API_UPSTREAM || 'http://127.0.0.1:3000';
export default defineConfig({
  server: { host: '127.0.0.1', proxy: { '/health': upstream } },
  preview: { host: '127.0.0.1', proxy: { '/health': upstream } },
});
