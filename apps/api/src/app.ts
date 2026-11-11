import Fastify from 'fastify';
import helmet from '@fastify/helmet';
import pg from 'pg';
import type { Config } from './config.js';

export async function createApp(config: Config) {
  const pool = new pg.Pool({ connectionString: config.databaseUrl, connectionTimeoutMillis: 2000, query_timeout: 2000, max: 5 });
  const app = Fastify({
    logger: config.logging ? { redact: ['req.headers.authorization', 'req.headers.cookie'] } : false,
    bodyLimit: 1048576,
    requestTimeout: 10000,
    trustProxy: false,
    disableRequestLogging: true,
  });
  pool.on('error', () => { app.log.error({ event: 'database_pool_error' }, 'Database connection unavailable'); });
  await app.register(helmet);
  app.addHook('onRequest', async (_request, reply) => { reply.header('Cache-Control', 'no-store'); });
  app.setErrorHandler((error, request, reply) => {
    const code = error && typeof error === 'object' && 'statusCode' in error ? error.statusCode : 500;
    const status = typeof code === 'number' && code >= 400 && code < 500 ? code : 500;
    request.log.error({ event: 'request_failed', request_id: request.id, status }, 'Request failed');
    void reply.status(status).send({ error: status < 500 ? 'invalid_request' : 'internal_error', request_id: request.id });
  });
  app.get('/health/live', async () => ({ status: 'ok' }));
  app.get('/health/ready', async (_request, reply) => {
    try {
      const result = await pool.query("SELECT version FROM schema_migrations WHERE version = '001'");
      if (result.rowCount !== 1) throw new Error('Schema unavailable');
      return { status: 'ok' };
    } catch { return reply.status(503).send({ status: 'unavailable' }); }
  });
  app.addHook('onClose', async () => { await pool.end(); });
  return app;
}
