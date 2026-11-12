# M1C — revisão independente substituta e adenda dos 40 pontos

**Change request:** `CR-M1C-REVIEW-001`

**Reviewed technical SHA:** [161e246](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/161e246614fb3da8cc3c950f9ed5cf0c42cc301e)

**Documentation SHA at review:** [2aaf4a3](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/2aaf4a3f39ee9f152eb12450226f4a39b9c10699)

**Reviewer:** Codex, agente independente `/root/m1c_h1_substitute_review`, GPT-6.1 SOL + Alto. Modelo e esforço confirmados pelos metadados do dispatch (`fork_turns=none`, `model=gpt-6.1-sol`, `reasoning_effort=high`); não por introspecção do runtime.

**Data:** 2026-11-12.

**Resultado final:** `INDEPENDENT_REVIEW = FAIL`; `M1C_GATE = FAIL`.

## Base e independência

O reviewer não implementou a migration 004, não herdou a sessão do implementador e trabalhou em modo read-only. Leu o Master FROZEN, contratos M1A, autorização M1C, finding ASTRA original, ordem H1 e CR. Examinou o código do SHA técnico exacto, migration 004, testes e relatórios brutos da CI [43167843976](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43167843976). Não alterou ficheiros nem executou testes contra terceiros. Recalculou 21/21 hashes de relatórios, verificou o guard FROZEN, a cadeia de migrations e os três jobs da CI. A suite integral não foi repetida: o CR §11 permite usar a evidência CI do SHA exacto.

O parecer focal inicial sobre HIGH-001 foi PASS. A pedido do agente principal, o mesmo reviewer concluiu depois os 40 pontos da ordem original M1C. A adenda identificou `M1C-SUB-MEDIUM-001` e **substituiu** a conclusão PASS inicial por FAIL. Esta é a decisão independente vigente. Não se inventou parecer ASTRA: o finding original ASTRA e a recusa automática da re-review permanecem em `ASTRA-REVIEW.md`.

## HIGH-001 — resultados H1-01 a H1-17

Referências: `migrations/004_clearance_temporal_approval_hardening.sql`, `migrations/003_authorization.sql` e os dois testes HIGH-001 em `tests/integration/authorization.test.mjs`, ambos aprovados na CI raw.

| Critério | Prova examinada | Resultado |
|---|---|---|
| H1-01 | Finito → ilimitado sem approval: API 403, clearance e versão intactas | PASS |
| H1-02 | Finito → ilimitado com approval exacta e checker distinto: 200, consumo e incremento de versão | PASS |
| H1-03 | Finito → finito posterior sem approval: 403 | PASS |
| H1-04 | Finito → finito posterior com approval: 200 e intervalo pedido persistido | PASS |
| H1-05 | `valid_from` anterior que amplia a janela: 403 sem approval | PASS |
| H1-06 | Rank e tempo maiores exigem approval; proposta aprovada permite alteração | PASS |
| H1-07 | Autoatribuição/auto-elevação: 403 | PASS |
| H1-08 | Maker como checker: 403 | PASS |
| H1-09 | Payload alterado na execução: 403 | PASS |
| H1-10 | Old row alterada após criação da approval: 403, approval PENDING | PASS |
| H1-11 | Autoridade do maker expirada: 403 | PASS |
| H1-12 | Autoridade do checker expirada: 403 | PASS |
| H1-13 | Policy version stale: 403 | PASS |
| H1-14 | Replay após consumo, mesmo com estado já igual: 403 | PASS |
| H1-15 | Duas execuções concorrentes: exactamente uma 200 e uma 403 | PASS |
| H1-16 | DML IAM directo nos dois runtimes e executor SQL directo sem approval: negados | PASS |
| H1-17 | API directa sem approval: 403 | PASS |

O comparador usa cobertura `tstzmultirange` dos intervalos ACTIVE no rank exigido ou superior. `valid_to = NULL` é limite superior ilimitado; cobertura finita não cobre proposta ilimitada. A redução temporal autorizada não é confundida com elevação. `clearance_change_payload` liga target, old row completa, nova classificação/rank, limites anteriores e propostos e policy version. O executor reconstrói o payload sob lock exclusivo, revalida maker/checker, compara JSON e hash SHA-256 e consome uma vez. Sucesso, audit e versões estão na mesma transacção. A prova de falha deliberada do audit writer é do mecanismo comum de rollback, não um novo teste exclusivo de clearance; o reviewer declarou esse limite.

## Boundaries relacionados e 40 pontos da ordem original

Referências examinadas: migration 002 (binding privado, sessão, deadlines), migrations 003/004 (decisão, grants, RLS, executores, SoD, delegação, approvals), API `AuthorizationPort`, testes M0/M1B/M1C e logs brutos do workflow. PASS combina análise estática e testes existentes; não indica novo teste local por linha. O teste WITH CHECK usa tabela técnica TEST; IAM operacional nega DML directo e usa executores tipados.

| # | Controlo | Resultado | Evidência resumida |
|---|---|---|---|
| 1 | Authorization model | PASS | Decisão conjuntiva autoritativa PostgreSQL e binding verificado |
| 2 | RBAC | PASS | Roles/permissions ACTIVE e concessões válidas |
| 3 | ABAC | PASS | Emprego, scope, localização, clearance, compartments e strength |
| 4 | Effective-grant isolation | PASS | Permission e scope/localização preservam o mesmo assignment |
| 5 | Sem expansão permission × scope | PASS | Teste negativo explícito de concessões cruzadas |
| 6 | Classification | PASS | Rank parametrizado e classificação inactiva nega |
| 7 | Clearance | PASS | Ausente/expirada nega; expansão temporal exige approval |
| 8 | Compartments | PASS | Todos os exigidos; parcial/inactivo nega |
| 9 | Default deny | PASS | Contexto, action ou metadados ausentes negam |
| 10 | API/RLS consistency | PASS | Matriz compara decisão, linhas SQL e HTTP |
| 11 | FORCE RLS | PASS | ENABLE/FORCE verificados nas tabelas IAM |
| 12 | USING/WITH CHECK | PASS | Policies reais; INSERT/UPDATE/DELETE em recurso técnico TEST |
| 13 | GUC tampering | PASS | GUC confrontada com binding privado; adulteração nega |
| 14 | Private binding integrity | PASS | Token, backend+xid, prazo, versões e marcador único |
| 15 | Pool context leakage | PASS | Pool max=1, commit/rollback/timeout, próximo pedido isolado |
| 16 | Savepoints | PASS | Rollback não transfere contexto/identidade |
| 17 | SECURITY DEFINER | PASS | Owners NOLOGIN, tipos, EXECUTE específico, helpers privados |
| 18 | search_path | PASS | Path fixo, schemas controlados e referências qualificadas |
| 19 | Runtime privileges | PASS | Sem flags/ownership/membership privilegiados |
| 20 | Direct IAM DML | PASS | INSERT/UPDATE/DELETE/TRUNCATE negados nos dois runtimes |
| 21 | SET ROLE | PASS | Tentativas de assumir owners negadas |
| 22 | Delegation ceilings | PASS | Delegação explícita, ceiling e clearance actual maker/checker |
| 23 | Grantable set | PASS | Vínculo por permission; posse isolada não concede delegação |
| 24 | Administrative scope | PASS | Scope kind/ID do target; cross-scope nega |
| 25 | Static SoD | PASS | Conflitos por roles/permissions no estado resultante |
| 26 | Temporal SoD | PASS | Sobreposições futuras negam; adjacência permite |
| 27 | Dynamic SoD | PASS | Actor=target e maker=checker negados |
| 28 | Maker-checker | PASS | Distinção e autoridade actual; role privilegiada/compartment sensível |
| 29 | Payload/version revalidation | PASS | JSON/hash exactos, old row, versões e autoridade reavaliados |
| 30 | Replay | PASS | Consumo único, replay e corrida negados |
| 31 | Self-escalation | PASS | Role, clearance, compartment e edição da própria role negados |
| 32 | Dois operadores administrativos | PASS | Capacidade mínima, remoção e corrida protegidas |
| 33 | Revocation concurrency | PASS | Revogação aguarda pedido anterior; binding posterior nega |
| 34 | Lock ordering | PASS | Policy → users/sessions ordenados; sem promoção do lock |
| 35 | Timeout/fail-closed | PASS | Deadlines, rollback/503, liberação de locks |
| 36 | Audit atomicity | PASS | Mutação, audit, aprovação e versões transaccionais |
| 37 | Negative authorization coverage / CI enforcement | **FAIL** | Testes negativos passaram neste SHA; pipeline pode ocultar falha futura |
| 38 | Privilege escalation paths | PASS | DML, owners, GUC, self-grants, delegação, SQL/API |
| 39 | M0 regression | PASS | Unit, database/API e browser no SHA exacto |
| 40 | M1B regression | PASS | Identidade, sessão e TLS/browser no SHA exacto |

Total: **39 PASS, 1 FAIL, 0 NOT VERIFIED**. A suspeita histórica não confirmada sobre `set_role_permission` foi examinada: executor verifica delegação, membros afectados e own-role; não se confirmou finding adicional nesse caminho.

## Regressão, integridade e scanners

O SHA técnico e os 21 relatórios raw correspondem; os três artefactos ligados a ele têm digests coerentes. `scripts/check-frozen.mjs` passou para Master + 11 contratos M1A. Entre o SHA original e o corrigido, migration 003 não mudou; migration 004 foi adicionada forward-only. O migrator valida checksums e a CI registou `001, 002, 003, 004`, incluindo testes de reexecução, drift e rollback. Master SHA-256: `7CDE06093C1A3F0D7EF7C463BC7EE08CB4FCAC48F4B149D377166C0FF171A667`.

No [run 43167843976](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43167843976), os três jobs terminaram `success`. Os relatórios brutos comprovam 4 unit + 38 integração (incluindo 2 H1) + 2 browser M0 + 4 browser TLS = **48/48**, zero falhas/skips. Semgrep 0 findings/errors; npm audit 0; Gitleaks source/history 0; Trivy SCA/API/web/PostgreSQL 0 HIGH/CRITICAL; quatro SBOM CycloneDX com 65/111/71/46 componentes. Estes resultados concretos são válidos para o SHA revisto, apesar do defeito no controlo de propagação de falhas futuras.

## Finding M1C-SUB-MEDIUM-001 — OPEN e bloqueante

- **Severity:** MEDIUM.
- **Component:** `.github/workflows/ci.yml:39`, etapa M0/M1B/M1C do job `Foundation tests`.
- **Evidence:** `run: npm run test:integration | tee artifacts/integration-tests.log`. O log raw do workflow, linhas 796–798, mostra `shell: /usr/bin/bash -e {0}`. Não existe `pipefail` no step ou default equivalente.
- **Impact:** o exit code do pipeline é o de `tee`; se os testes de integração falharem mas `tee` escrever o log, o job poderá reportar sucesso. Isso enfraquece o bloqueio automático de regressões de autorização, RLS, SoD e sessões. Não é bypass runtime demonstrado. Os 38 testes deste SHA efectivamente passaram no log raw.
- **Required remediation:** propagar a falha do comando de testes, por exemplo activando `set -o pipefail`; demonstrar com falha deliberada controlada que o step falha; executar nova CI no SHA corrigido e revisão independente focalizada.
- **Gate impact:** BLOCKING. O Master exige que falhas críticas bloqueiem promoção; a ordem original M1C exige avaliação individual de MEDIUM e não permite aceitar automaticamente um finding relevante. Não existe autorização para aceitar este desvio.

## Findings e decisão independente vigente

CRITICAL: 0 novos. HIGH: 0 novos. MEDIUM: 1 OPEN (`M1C-SUB-MEDIUM-001`). LOW: 0. O finding original `M1C-ASTRA-HIGH-001` está **FIXED tecnicamente**, mas fica **OPEN FOR GOVERNANCE** pelo ramo FAIL do CR. A conclusão PASS focal inicial foi substituída pela adenda dos 40 pontos.

```text
INDEPENDENT_REVIEW = FAIL
M1C_GATE = FAIL
M1D = BLOCKED
M2 = BLOCKED
```

A próxima acção é uma autorização específica para corrigir o controlo CI, demonstrar que uma falha deliberada não fica mascarada, executar nova CI e pedir revisão independente focalizada antes de reavaliar o gate. M1D/M2 não foram iniciados.
