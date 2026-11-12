import Fastify from 'fastify';
import helmet from '@fastify/helmet';
import pg from 'pg';
import type { Config } from './config.js';
import { readFile } from 'node:fs/promises';
import { registerAuth, makeRequestId } from './auth.js';

export async function createApp(config: Config) {
  const pool = new pg.Pool({ connectionString: config.databaseUrl, connectionTimeoutMillis: 2000, query_timeout: 5000, max: config.auth?.poolSize||5 });
  const tlsOptions=config.tls?{https:{cert:await readFile(config.tls.certFile),key:await readFile(config.tls.keyFile)}}:{};
  const app = Fastify({
    ...tlsOptions,
    logger: config.logging ? { stream:config.logStream,redact: ['req.headers.authorization', 'req.headers.cookie', 'req.headers["x-csrf-token"]', 'req.body.password', 'req.body.current_password', 'req.body.new_password', 'res.headers["set-cookie"]'] } : false,
    genReqId: makeRequestId,
    ajv:{customOptions:{removeAdditional:false,coerceTypes:false}},
    bodyLimit: 1048576,
    requestTimeout: 10000,
    trustProxy: config.trustedProxyIPs?.length ? config.trustedProxyIPs : false,
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
      if(config.auth) {const authSchema=await pool.query("SELECT version FROM schema_migrations WHERE version IN('002','003','004')");if(authSchema.rowCount!==3)throw new Error('Authentication schema unavailable');}
      return { status: 'ok' };
    } catch { return reply.status(503).send({ status: 'unavailable' }); }
  });
  if(config.auth)await registerAuth(app,pool,config.auth);
  app.addHook('onClose', async () => { await pool.end(); });
  return app;
}
