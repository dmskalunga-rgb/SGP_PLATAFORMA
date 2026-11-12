# M1 — relatório de testes M1C

Suite candidata: 4 testes unitários, 36 de integração PostgreSQL/API (19 M1C, 13 M1B, 4 M0), 2 browser M0 e 4 browser TLS de identidade/autorização. Sem mocks operacionais. Bases TEST efémeras e credenciais aleatórias são removidas pelos respectivos harnesses.

A suite M1C compara API/SQL, grants não cartesianos, scope/location, todos os limiares de rank, clearances ausentes/expiradas, todos os compartimentos, estados inactivos, versões/context/GUC, FORCE RLS e ACL por runtime; INSERT/UPDATE WITH CHECK e DELETE separado em tabela técnica TEST; comandos reais/negativos por executor; SoD futuro/indirecto; delegação, approvals, replay, maker expirado; audit rollback; pool/savepoints; revogação e remoções concorrentes. Três E2Es reais provam configuração/acesso, maker-checker e revogação.

Frontend: botão indisponível ocultado após retirada real de permission; API directa continua a negar. Regressão M1B preserva TLS/cookie/CSRF/password/lockout/sessões/pool/deadline real.

Resultados locais e hashes em EVIDENCE/M1/M1C/CHECKS.json. CI e revisão independente são condições separadas; ver CI.md nessa pasta e atestação final do commit. Não confundir execução local com gate remoto.

Actualização H1: dois testes PostgreSQL TEST adicionais cobrem extensão finita → ilimitada/finita, redução, rank, maker/checker, payload, versão, expiração, replay, API/SQL e auditoria. Foco 2/2; regressão completa local 4 unit + 38 integração + 2 browser M0 + 4 browser TLS = 48/48, zero falhas/skips. A CI do novo SHA é obrigatória.

CI do SHA técnico corrigido: [run 43167843976](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43167843976), mesmos 48 testes PASS, zero falhas/skips. Isto não substitui a re-review independente ASTRA requerida para o gate.

O revisor substituto confirmou independentemente 21/21 hashes de relatórios e 48/48 testes realmente aprovados. Identificou porém que `.github/workflows/ci.yml` não propaga necessariamente o exit code de `npm run test:integration` através de `tee`. A execução deste SHA é válida; o enforcement de falha futura na CI está aberto como `M1C-SUB-MEDIUM-001` e bloqueia o gate.


## Fecho MEDIUM-001 — 2026-11-12

Correcção focal publicada em [0643595](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/0643595faa20422643aa712c104d302f2f743ba1). [CI 43205905235](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43205905235): três jobs PASS, 48/48 testes normais, zero falhas/skips, scanners PASS e quatro SBOM. Provas remotas: producer23/pipeline23, sucesso0, teste Node temporário falhado/pipeline1. Ambos os pipelines críticos usam Bash/pipefail e conservam logs. Business code e migrations intactos.

Re-review independente read-only `/root/medium_final_review`, dispatch GPT-6.1 SOL + Alto, fork sem contexto: oito critérios §14 PASS, sem novos findings CRITICAL/HIGH/MEDIUM/LOW. Provas e limites em MEDIUM-001-CI-FAIL-CLOSED.md. O teste falhado controlado usa node:test temporário, não PostgreSQL; regressão PostgreSQL normal passou. O checker protege o formato actual dos dois steps e não é parser geral YAML/Shell.

Esta decisão substitui os estados FAIL anteriores preservados neste histórico: **M1C-ASTRA-HIGH-001 = CLOSED; M1C-SUB-MEDIUM-001 = CLOSED; INDEPENDENT_REVIEW = PASS; M1C_GATE = PASS; M1D = BLOCKED_PENDING_EXPLICIT_AUTHORIZATION; M2 = BLOCKED.** A atestação exacta com SHA documental/CI encontra-se em refs/notes/m1c-gate. STOP antes de M1D/M2.
