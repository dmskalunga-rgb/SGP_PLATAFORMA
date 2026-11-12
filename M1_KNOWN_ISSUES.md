# M1C — riscos residuais e limites

A decisão verificável encontra-se em EVIDENCE/M1/M1C/CI.md/atestação final. Scans ou review pendentes nunca equivalem a PASS.

| Item | Tratamento / limite |
|---|---|
| auth_runtime/processo auth privilegiado | Boundary M1B separado; RLS não neutraliza comprometimento total do processo |
| Migração/DBA | Fora da defesa runtime; sem garantia de imutabilidade contra superuser |
| Enrollment M1B existente | Deploy valida dois operadores reais e executa inscrição privada uma única vez; metadados ausentes negam |
| Classificação/delegação/scopes institucionais | Configuração controlada; bootstrap só nível mínimo explícito, sem clearance máxima automática |
| Roles administrativas já atribuídas | Conteúdo privilegiado não é alterado por este baseline; configurar role vazia e aprovar atribuição distinta |
| Revogação de assignment administrativo | Comando conservador recusa; protege capacidade enquanto administração completa permanece M1D |
| Contenção IAM | Serialização global deliberada, timeouts limitados; medir hardware/latência antes de optimizar por ADR |
| Argon2/lista de passwords | Baseline M1B preservada; validar hardware e ampliar corpus institucional antes de produção |
| TLS/secrets/recuperação/retenção/SIEM | Provisionamento institucional externo; sem backdoor e sem deployment produção alegado |
| Fastify/NO_COLOR | Avisos não bloqueantes herdados; sem falha de testes |
| Main branch protection | Configuração herdada de M0; push autorizado sem force, CI obrigatória por SHA |

Não há autorização para M1D/M2. PASS M1C não fecha M1 completo nem autoriza próxima fase. Qualquer finding crítico/HIGH não resolvido da revisão/CI mantém gate FAIL e fases seguintes bloqueadas.

Finding activo: `M1C-ASTRA-HIGH-001` — extensão temporal de clearance sem maker-checker no SHA original. Corrigido na candidatura local via migration 004, mas ainda OPEN para governação até CI remota e ASTRA re-review do novo commit. `M1C_GATE = FAIL`; M1D/M2 bloqueados.

Actualização: a CI remota da correcção passou no [run 43167843976](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43167843976). A re-review ASTRA do SHA corrigido não ocorreu: a revisão automática rejeitou a tarefa por possível risco de cibersegurança. Finding OPEN para closure formal; M1C_GATE FAIL. Não há autorização para M1D/M2.

`CR-M1C-REVIEW-001`: revisor substituto independente confirmou HIGH-001 FIXED tecnicamente, mas registou `M1C-SUB-MEDIUM-001` OPEN/BLOCKING em `.github/workflows/ci.yml:39`: `npm run test:integration | tee` sem `pipefail` pode mascarar falhas futuras. Os 48 testes observados passaram realmente. É necessária correcção focal do workflow, prova de falha controlada, nova CI e revisão independente antes de reavaliar o gate. M1C_GATE FAIL; M1D/M2 BLOCKED.


## Fecho MEDIUM-001 — 2026-11-12

Correcção focal publicada em [0643595](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/0643595faa20422643aa712c104d302f2f743ba1). [CI 43205905235](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43205905235): três jobs PASS, 48/48 testes normais, zero falhas/skips, scanners PASS e quatro SBOM. Provas remotas: producer23/pipeline23, sucesso0, teste Node temporário falhado/pipeline1. Ambos os pipelines críticos usam Bash/pipefail e conservam logs. Business code e migrations intactos.

Re-review independente read-only `/root/medium_final_review`, dispatch GPT-6.1 SOL + Alto, fork sem contexto: oito critérios §14 PASS, sem novos findings CRITICAL/HIGH/MEDIUM/LOW. Provas e limites em MEDIUM-001-CI-FAIL-CLOSED.md. O teste falhado controlado usa node:test temporário, não PostgreSQL; regressão PostgreSQL normal passou. O checker protege o formato actual dos dois steps e não é parser geral YAML/Shell.

Esta decisão substitui os estados FAIL anteriores preservados neste histórico: **M1C-ASTRA-HIGH-001 = CLOSED; M1C-SUB-MEDIUM-001 = CLOSED; INDEPENDENT_REVIEW = PASS; M1C_GATE = PASS; M1D = BLOCKED_PENDING_EXPLICIT_AUTHORIZATION; M2 = BLOCKED.** A atestação exacta com SHA documental/CI encontra-se em refs/notes/m1c-gate. STOP antes de M1D/M2.
