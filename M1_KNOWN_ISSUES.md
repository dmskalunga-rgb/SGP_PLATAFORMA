# M1 — riscos e pendências no checkpoint M1A

O estado do gate arquitectural e dos findings da revisão está em EVIDENCE/M1/M1A/M1A-GATE.md e ASTRA-REVIEW.md. M1B/C/D não estão executados; isso não é aprovação parcial do M1-GATE final.

| Risco / obrigação | Dono / fecho exigido |
|---|---|
| Functions SECURITY DEFINER, RLS interno sem recursão e binding privado ainda sem implementação/prova | Engenharia M1C: PostgreSQL real, SQL directo/API, privilégios e adversarial suite antes do gate |
| Lock global reduz paralelismo de mutações IAM; lock/statement/context timeouts são baseline | Engenharia M1B/C: medir carga, concorrência, latência; alteração só por ADR e revisão |
| auth_runtime/processo auth constitui boundary confiável privilegiado | Operações/engenharia: secret isolation, grants mínimos, telemetria sanitizada e threat tests |
| Hashing Argon2id e quotas precisam calibração em hardware alvo | Engenharia M1B: limites CPU/memória e DOS, sem degradar silenciosamente |
| Classificações/sensibilidade/delegação requerem validação institucional | PNA antes de produção; parametrização e mudança auditada |
| Bootstrap e recuperação requerem dois operadores reais e procedimento protegido | Operador institucional; sem seed de identidades fictícias, auto-aprovação ou backdoor |
| Retenção de audit/sessões, off-host evidence e protecção contra DBA | Operações/PNA antes de produção; RLS não promete imutabilidade contra superuser |
| Protecção de main não activa, herdado M0 | Governação do repositório; não modificado nesta entrega documental |

Nenhuma destas obrigações futuras é tratada como teste passado. Nova autorização explícita é necessária para M1B mesmo após aprovação M1A. M2 permanece bloqueado.
