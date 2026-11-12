# SGP-DISPO Repository Instructions

## Canonical Authority

Before any substantive implementation, read:

1. SGP-DISPO-MASTER-v1.1-FROZEN-FINAL.md
2. docs/governance/MASTER-AUTHORITY.md
3. the current authorized milestone plan
4. relevant current gate/evidence documents

The canonical authority is:

SGP-DISPO-MASTER-v1.1-FROZEN-FINAL.md

SGP-DISPO-MASTER-v1.0-FROZEN.md is historical and MUST be preserved.

## Existing Repository

This is NOT a new repository.

DO NOT execute the historical M0 bootstrap instructions.

Mandatory continuity rule:

RESUME — DO NOT RESTART.
EXTEND — DO NOT REWRITE.
MIGRATE FORWARD — DO NOT MUTATE HISTORY.
PRESERVE PASSED GATES.

## Existing Engineering Guarantees

Do not rebuild, bypass or weaken approved M0/M1 foundations.

Preserve:

- authentication;
- sessions;
- AuthorizationPort;
- RBAC;
- ABAC;
- RLS / FORCE RLS;
- security context;
- classification;
- clearance;
- compartments;
- SoD;
- maker-checker;
- audit;
- fail-closed CI.

## Migrations

Published migrations are immutable.

All schema evolution is FORWARD-ONLY.

Never edit an already published migration merely to satisfy a new milestone.

## Data

PostgreSQL is the source of truth.

No operational:

- mocks;
- fake data;
- demo data;
- disconnected frontend;
- fake buttons;
- decorative routes.

TEST/CI/E2E fixtures are permitted only according to the Master.

## Before Editing

Perform a read-only preflight:

- git status;
- current HEAD;
- published migrations;
- gate evidence;
- currently authorized milestone;
- local uncommitted work.

Preserve valid uncommitted work.

Never reset, clean or discard work without explicit authorization.

## Milestone Control

Implement ONLY the milestone explicitly authorized by the human authority.

A milestone PASS does not authorize the next milestone.

Do not start M2 or any later milestone automatically.

## Security

Frontend visibility is not authorization.

Security-sensitive operations must preserve:

API authorization
→ RBAC/ABAC
→ RLS
→ classification/compartments
→ SoD
→ audit

Fail closed.

## Definition of Done

Do not declare DONE without applicable:

- real frontend;
- real API;
- real PostgreSQL persistence;
- migration when required;
- business rules;
- authorization;
- RLS when required;
- audit;
- validation;
- error handling;
- tests;
- security tests;
- documentation;
- evidence.

## Gate Independence

Critical implementation must not self-approve its own final gate.

Use independent review according to the Master.

## Change Control

Do not edit SGP-DISPO-MASTER-v1.1-FROZEN-FINAL.md during ordinary implementation.

Any future Master change requires a formal Change Request.
