export type Config = { databaseUrl: string; host: string; port: number; logging: boolean };

export function readConfig(env: Record<string, string | undefined>): Config {
  const databaseUrl = env.DATABASE_URL;
  if (!databaseUrl) throw new Error('DATABASE_URL is required');
  let parsed: URL;
  try { parsed = new URL(databaseUrl); } catch { throw new Error('DATABASE_URL is invalid'); }
  if (!['postgres:', 'postgresql:'].includes(parsed.protocol)) throw new Error('PostgreSQL is required');
  const port = Number(env.PORT || 3000);
  if (!Number.isInteger(port) || port < 1 || port > 65535) throw new Error('PORT is invalid');
  const environment = env.NODE_ENV || 'development';
  if (!['development', 'test', 'staging', 'production'].includes(environment)) throw new Error('NODE_ENV is invalid');
  return { databaseUrl, port, host: env.HOST || '127.0.0.1', logging: env.LOG_LEVEL !== 'silent' };
}
