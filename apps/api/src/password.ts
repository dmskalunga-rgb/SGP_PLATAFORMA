import * as argon2 from 'argon2';
import { randomBytes } from 'node:crypto';

export type PasswordPolicy = { memoryCost: number; timeCost: number; parallelism: number; minimum: number; maximum: number; concurrency: number };
export const baselinePasswordPolicy: PasswordPolicy = { memoryCost: 65536, timeCost: 3, parallelism: 1, minimum: 15, maximum: 128, concurrency: 2 };
// Public weak-password dictionary, never credentials or operational users.
const commonPasswords = new Set(['passwordpassword','123456789012345','1234567890123456','qwertyuiopasdfgh','letmeinletmeinletmein']);
export class HashCapacityError extends Error {}
export function validatePasswordPolicy(p: PasswordPolicy) {
  for (const n of Object.values(p)) if (!Number.isInteger(n)) throw new Error('Invalid password policy');
  if (p.memoryCost < 65536 || p.memoryCost > 262144 || p.timeCost < 3 || p.timeCost > 10 || p.parallelism < 1 || p.parallelism > 4 || p.minimum < 15 || p.maximum > 128 || p.minimum > p.maximum || p.concurrency < 1 || p.concurrency > 4) throw new Error('Invalid password policy');
}
export class PasswordService {
  private active = 0;
  private dummy = '';
  private constructor(readonly policy: Readonly<PasswordPolicy>) {}
  static async create(policy: PasswordPolicy = baselinePasswordPolicy) {
    validatePasswordPolicy(policy);
    const service = new PasswordService(Object.freeze({ ...policy }));
    service.dummy = await service.hash(randomBytes(32).toString('base64url'));
    return service;
  }
  normalize(value: string) { return value.normalize('NFC'); }
  acceptable(value: string) {
    const normalized = this.normalize(value);
    const length = [...normalized].length;
    return length >= this.policy.minimum && length <= this.policy.maximum && !commonPasswords.has(normalized);
  }
  private async bounded<T>(fn: () => Promise<T>) {
    if (this.active >= this.policy.concurrency) throw new HashCapacityError('Hash capacity reached');
    this.active++;
    try { return await fn(); } finally { this.active--; }
  }
  hash(value: string) {
    if (!this.acceptable(value)) throw new Error('Password policy rejected');
    return this.bounded(() => argon2.hash(this.normalize(value), { type: argon2.argon2id, memoryCost: this.policy.memoryCost, timeCost: this.policy.timeCost, parallelism: this.policy.parallelism, hashLength: 32, salt: randomBytes(16), version: 0x13 }));
  }
  async verify(hash: string | undefined, value: string) {
    const encoded = hash || this.dummy;
    const metadata = /^\$argon2id\$v=19\$m=(\d+),t=(\d+),p=(\d+)\$[A-Za-z0-9+/]{22}\$[A-Za-z0-9+/]{43}$/.exec(encoded);
    if (!metadata || Number(metadata[1]) > 262144 || Number(metadata[2]) > 10 || Number(metadata[3]) > 4) throw new Error('Unsupported credential metadata');
    return this.bounded(() => argon2.verify(encoded, this.normalize(value)));
  }
  needsRehash(hash: string) { return argon2.needsRehash(hash, this.policy); }
}
