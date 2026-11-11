import { isIP } from 'node:net';
import { baselinePasswordPolicy, validatePasswordPolicy } from './password.js';
import type { AuthConfig } from './auth.js';
export type Config = { databaseUrl: string; host: string; port: number; logging: boolean; logStream?:{write:(message:string)=>void}; auth?: AuthConfig; trustedProxyIPs?: string[]; tls?: {certFile:string;keyFile:string} };

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
  let auth: AuthConfig | undefined;
  const trustedProxyIPs=(env.AUTH_TRUSTED_PROXY_IPS||'').split(',').filter(Boolean);
  if(trustedProxyIPs.some(ip=>!isIP(ip)))throw new Error('Only explicit proxy IPs allowed');
  if(env.AUTH_DATABASE_URL) {
    let source:URL;
    try{source=new URL(env.AUTH_DATABASE_URL);}catch{throw new Error('AUTH_DATABASE_URL is invalid');}
    if(!['postgres:','postgresql:'].includes(source.protocol) || source.username===parsed.username || !source.username || !parsed.username)throw new Error('Separate PostgreSQL auth/runtime identities required');
    const origin=new URL(env.AUTH_ORIGIN||'');
    if(origin.protocol!=='https:' || origin.origin!==env.AUTH_ORIGIN)throw new Error('Exact HTTPS AUTH_ORIGIN required');
    if(['staging','production'].includes(environment) && (parsed.searchParams.get('sslmode')!=='verify-full'||source.searchParams.get('sslmode')!=='verify-full'))throw new Error('Verified PostgreSQL TLS required');
    const passwordPolicy={...baselinePasswordPolicy,memoryCost:Number(env.ARGON2_MEMORY_KIB||65536),timeCost:Number(env.ARGON2_TIME_COST||3),parallelism:Number(env.ARGON2_PARALLELISM||1),concurrency:Number(env.AUTH_HASH_CONCURRENCY||2),minimum:Number(env.PASSWORD_MIN_LENGTH||15),maximum:Number(env.PASSWORD_MAX_LENGTH||128)};
    validatePasswordPolicy(passwordPolicy);
    auth={databaseUrl:env.AUTH_DATABASE_URL,origin:origin.origin,passwordPolicy};
  }
  const tls=env.TLS_CERT_FILE&&env.TLS_KEY_FILE?{certFile:env.TLS_CERT_FILE,keyFile:env.TLS_KEY_FILE}:undefined;
  if(Boolean(env.TLS_CERT_FILE)!==Boolean(env.TLS_KEY_FILE))throw new Error('TLS key and certificate must be supplied together');
  return { databaseUrl, port, host: env.HOST || '127.0.0.1', logging: env.LOG_LEVEL !== 'silent', auth, trustedProxyIPs, tls };
}
