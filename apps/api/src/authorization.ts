import type pg from 'pg';

export type AuthorizationReason = 'AUTHORIZED' | 'AUTHN_REQUIRED' | 'SESSION_EXPIRED' | 'SESSION_REVOKED' | 'USER_INACTIVE' | 'PERMISSION_DENIED' | 'SCOPE_DENIED' | 'CLEARANCE_DENIED' | 'COMPARTMENT_DENIED' | 'STRENGTH_DENIED' | 'SOD_DENIED' | 'DELEGATION_DENIED' | 'CONTEXT_MISSING' | 'CONTEXT_TAMPERED' | 'POLICY_UNKNOWN';
export type AuthorizationDecision = Readonly<{
  decision: 'ALLOW' | 'DENY';
  internal_reason: AuthorizationReason;
  policy_version: number | null;
  decision_id: string;
}>;
export interface AuthorizationPort {
  authorize(subject: string, action: string, resource: {type: string; id: string}, context: Readonly<Record<string, unknown>>): Promise<AuthorizationDecision>;
}

// Uses the request's pinned transaction client. No second pool or decision cache.
export class PostgreSQLAuthorization implements AuthorizationPort {
  constructor(private readonly client: pg.PoolClient) {}
  async authorize(subject: string, action: string, resource: {type: string; id: string}, context: Readonly<Record<string, unknown>>): Promise<AuthorizationDecision> {
    const result = await this.client.query('SELECT iam.authorize($1,$2,$3,$4,$5) AS decision', [subject,action,resource.type,resource.id,context]);
    return Object.freeze(result.rows[0].decision as AuthorizationDecision);
  }
}
