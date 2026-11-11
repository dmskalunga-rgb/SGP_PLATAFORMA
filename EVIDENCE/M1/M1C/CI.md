# M1C — publicação e CI

Repository: https://github.com/dmskalunga-rgb/SGP_PLATAFORMA
Branch: main
Base: [f1b146b](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/f1b146b6fe128adb37271b08e419b1be1b3007c1).

Workflow: `.github/workflows/ci.yml`, jobs Foundation tests / Source security and SBOM / Container security. O primeiro inclui regressão M0/M1B, 19 testes M1C e browser TLS com prova de autorização. Os scanners e quatro SBOM são obrigatórios. Testes não usam mocks operacionais.

A evidência versionada é a candidatura anterior ao commit/CI. O SHA final e o resultado da CI desse mesmo SHA não podem ser inscritos recursivamente dentro do seu próprio commit. A atestação final, incluindo workflow/run/job/artifact IDs, hashes, revisão ASTRA e gate, será publicada numa Git note `refs/notes/m1c-gate` anexada ao commit verificado, seguindo o mecanismo M1A/M1B. Consultar com `git fetch origin refs/notes/m1c-gate:refs/notes/m1c-gate` e `git notes --ref=m1c-gate show <commit>`.

Antes dessa atestação: PENDING_REMOTE_CI_AND_INDEPENDENT_REVIEW. A existência destes documentos não declara PASS. Logs locais e downloads CI ficam em `artifacts/`, sem credenciais e fora do source publicado; logs remotos e artefactos são fornecidos pelo workflow.
