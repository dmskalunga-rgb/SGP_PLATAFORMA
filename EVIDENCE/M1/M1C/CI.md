# M1C — publicação e CI

Repository: https://github.com/dmskalunga-rgb/SGP_PLATAFORMA
Branch: main
Base: [f1b146b](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/f1b146b6fe128adb37271b08e419b1be1b3007c1).

Workflow: `.github/workflows/ci.yml`, jobs Foundation tests / Source security and SBOM / Container security. O primeiro inclui regressão M0/M1B, 19 testes M1C e browser TLS com prova de autorização. Os scanners e quatro SBOM são obrigatórios. Testes não usam mocks operacionais.

A evidência versionada é a candidatura anterior ao commit/CI. O SHA final e o resultado da CI desse mesmo SHA não podem ser inscritos recursivamente dentro do seu próprio commit. A atestação final, incluindo workflow/run/job/artifact IDs, hashes, revisão ASTRA e gate, será publicada numa Git note `refs/notes/m1c-gate` anexada ao commit verificado, seguindo o mecanismo M1A/M1B. Consultar com `git fetch origin refs/notes/m1c-gate:refs/notes/m1c-gate` e `git notes --ref=m1c-gate show <commit>`.

Antes dessa atestação: PENDING_REMOTE_CI_AND_INDEPENDENT_REVIEW. A existência destes documentos não declara PASS. Logs locais e downloads CI ficam em `artifacts/`, sem credenciais e fora do source publicado; logs remotos e artefactos são fornecidos pelo workflow.

## Remediação HIGH-001

O run [43093293944](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43093293944) concluiu os três jobs com sucesso para o SHA técnico original, mas ASTRA encontrou o finding HIGH-001 nesse SHA. Portanto esse run não valida a correcção. A migration incremental 004, API e testes novos exigem commit novo, CI completa no novo SHA, scans/SBOM correspondentes e re-review independente. A decisão final será atestada em `refs/notes/m1c-gate`; até então `M1C_GATE = FAIL`, M1D/M2 bloqueados.

## CI do commit técnico corrigido

Commit: [161e246](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/161e246614fb3da8cc3c950f9ed5cf0c42cc301e). [Workflow 43167843976](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43167843976): Foundation tests PASS; Source security and SBOM PASS; Container security PASS. Artefactos ligados ao SHA: tests ID `13920842394`, container security ID `13920817461`, source security ID `13920498330`. Relatórios brutos e respectivos hashes locais em `artifacts/M1C-H1-REVIEW-INPUT.json` (não versionados); artefactos remotos disponíveis no workflow.

Verificação dos relatórios: 4 unit, 38 integração (incluindo 2 H1), 2 browser M0, 4 browser TLS = 48 testes, zero falhas/skips. Gitleaks source/history zero, Semgrep zero findings/errors, npm audit zero, Trivy SCA/API/web/PostgreSQL zero HIGH/CRITICAL; quatro SBOM CycloneDX válidos. Master + 11 FROZEN exactos. A revisão automática recusou a tarefa ASTRA no SHA corrigido por possível risco de cibersegurança; não existe parecer independente PASS. `M1C_GATE = FAIL` e finding HIGH-001 permanece OPEN para governação.
