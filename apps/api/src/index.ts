import { createApp } from './app.js';
import { readConfig } from './config.js';

const config = readConfig(process.env);
const app = await createApp(config);
for (const signal of ['SIGTERM', 'SIGINT'] as const) {
  process.once(signal, () => { void app.close(); });
}
await app.listen({ host: config.host, port: config.port });
