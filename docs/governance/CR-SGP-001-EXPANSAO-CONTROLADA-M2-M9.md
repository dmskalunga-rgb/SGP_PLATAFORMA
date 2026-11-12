# CR-SGP-001 — EXPANSÃO CONTROLADA DOS MILESTONES M2–M9

## Estado da decisão

```text
APPROVED
INCORPORATED INTO SGP-DISPO-MASTER-v1.1-FROZEN
```

## Razão

Consolidar no Master canónico os domínios funcionais e transversais necessários para que o SGP-DISPO cubra integralmente o ciclo patrimonial institucional, sem fragmentar o roadmap, sem criar milestones posteriores a M10 e sem destruir garantias já implementadas.

## Requisitos afectados

```text
Secção 9 — Domínios Funcionais Obrigatórios
M2 — Organização e Localizações
M3 — Cadastro / Património E2E
M4 — Afectação, Movimentação e Custódia
M5 — Inventário Físico e Reconciliação
M6 — Manutenção e Ciclo de Vida
M7 — Auditoria, Relatórios, Analytics e Governança
M8 — Integração, Hardening e Operabilidade
M9 — System Acceptance & Production Readiness
```

## Arquitectura afectada

A arquitectura fundamental não é substituída. Mantêm-se:

```text
React + TypeScript + Vite
Node.js + TypeScript + Fastify
PostgreSQL como source of truth
RBAC + ABAC + RLS + Need-to-Know + Least Privilege
Migrations versionadas
OpenAPI /api/v1
On-Premises / Rede privada PNA
Frontend → API → Services → Rules → Authorization → Repository → PostgreSQL
```

## Impacto de segurança

```text
NO SECURITY REDUCTION
NO RLS REDUCTION
NO AUTHORIZATION BYPASS
NO AUDIT REDUCTION
NO MOCK RELAXATION
```

Os novos domínios herdam integralmente os controlos de M0/M1.

## Impacto de base de dados

Novas entidades, relações, constraints e migrations poderão ser introduzidas a partir de M2 conforme DoR/ADR. É proibido reescrever migrations já publicadas para acomodar esta expansão.

## Impacto de compatibilidade

```text
BACKWARD COMPATIBLE BY DESIGN
```

Tudo o que foi implementado e aprovado em M0 e M1 permanece válido. Esta consolidação não exige reconstruir autenticação, autorização, RLS, security context, auditoria, CI, sessões, maker-checker ou demais controlos já aprovados.

## Impacto de migrations

```text
FORWARD-ONLY
```

Migrations já publicadas permanecem imutáveis. Expansões futuras utilizam novas migrations numeradas sequencialmente.

## Impacto de testes

A suite existente permanece obrigatória e verde. Cada milestone acrescentará os testes específicos dos novos domínios sem remover regressões anteriores.

## Rollback Plan

Não existe rollback destrutivo de código já aprovado. Se um requisito novo não puder ser implementado com segurança, o milestone correspondente permanece `BLOCKED` ou `GATE_FAILED`; os milestones anteriores não são desfeitos.

## Decisão

```text
INCORPORATE NEW DOMAINS INSIDE M2–M9
DO NOT CREATE M11/M12/M13
PRESERVE M0–M1 IMPLEMENTATION
PRESERVE M0→M10 ORDER
PRESERVE ALL EXISTING GATES
```

## Aprovação

Aprovação humana expressa para consolidação do Master e congelamento final em 12 de Novembro de 2026.

---
