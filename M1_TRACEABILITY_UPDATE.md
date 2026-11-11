# M1 — rastreabilidade de desenho M1A

Cada linha cobre requisito → contrato → ADR → prova documental. Código/migration/API/teste executável = não implementados nesta subfase, bloqueados até autorização. Referências de testes são obrigações futuras, não resultados. Evidência comum: EVIDENCE/M1/M1A/{ASTRA-REVIEW.md,M1A-GATE.md,CHECKS.json,FREEZE-MANIFEST.json}.

| ID | Requisito / ordem M1 | Contrato (docs/security) | ADR | Teste futuro / subfase |
|---|---|---|---|---|
| SGP-IAM-001 | Identidade mínima, lifecycle, username não email (§4.1,9) | SECURITY-CONTEXT-CONTRACT, SESSION-MODEL | 007,009 | CTX-001, login status / B |
| SGP-IAM-002 | Auth interna e adaptadores futuros (§10,15 master) | SESSION-MODEL | 009 | Argon2, lockout, rate-limit / B |
| SGP-SES-001 | Sessão revogável, expiração, rotação (§11–13) | SESSION-MODEL, AUTHORIZATION-MODEL | 008,009 | Expiry/revocation/concurrency / B |
| SGP-CTX-001 | Envelope explícito e origem DB (§4.2) | SECURITY-CONTEXT-CONTRACT | 007 | CTX-001/004/005 / C |
| SGP-CTX-002 | Propagação Fastify/transacção/SET LOCAL (§4.3,22) | SECURITY-CONTEXT-CONTRACT, RLS-DESIGN | 007,010 | CTX-002/003, RLS-006/007 / C |
| SGP-AUT-001 | authorize default deny e servidor (§4.4,21) | AUTHORIZATION-MODEL | 008 | AUTH-001–003 API/SQL / C |
| SGP-RBA-001 | users/roles/permissions/vínculos (§4.5,19) | RBAC-ABAC-MODEL | 008 | Grants activos, scope-bound, role edits / C |
| SGP-ABA-001 | Atributos conjuntivos sem M2 (§4.6,20) | RBAC-ABAC-MODEL | 007,008 | Retirar cada atributo; unknown deny / C |
| SGP-CLS-001 | Classificação configurável e clearance (§4.7) | CLASSIFICATION-MODEL | 008 | CLS-001/003 / C |
| SGP-CMP-001 | ALL compartments + need-to-know (§4.8) | CLASSIFICATION-MODEL | 008 | CLS-002 / C |
| SGP-SOD-001 | Incompatibilidades e maker-checker (§4.9,32) | SEGREGATION-OF-DUTIES | 008 | SOD-001–006 / C,D |
| SGP-RLS-001 | FORCE/RLS real, privilege/pool boundaries (§22–27) | RLS-DESIGN | 010 | RLS-001–012 SQL directo/API / C |
| SGP-AUD-001 | Eventos IAM e negações, atomicidade (§13,34; master22) | SESSION-MODEL, AUTHORIZATION-MODEL | 008,009 | Falhas audit, reconstruct / B,D |
| SGP-GOV-001 | M1A only, regressão M0, freeze/gate (§6,38,46–49) | M1A-PLAN, checkpoint reports | 007–010 | CHECKS + review; regressão completa futura |

M2 e workflows patrimoniais não têm código ou entregável nesta matriz. Referências opacas de scope não representam implementação de hierarquia organizacional.
