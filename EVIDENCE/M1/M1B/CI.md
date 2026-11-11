# CI e publicação M1B

Workflow existente preserva os jobs Foundation tests, Source security and SBOM, Container security. Foundation acrescenta frozen guard (manifesto pinado + master + onze hashes), testes unit/DB/API de autenticação e sessões, calibração Argon2 e três E2E de browser com TLS TEST efémero. M0 unit/DB/browser/health continuam executados. O job de segurança mantém audit, Gitleaks source+history, Semgrep, Trivy SCA e SBOM; imagens continuam a passar smoke/nonroot/read-only/least privilege, Trivy e CycloneDX.

Sequência obrigatória: candidato → secret scan → commit/push sem force → CI do SHA exacto → registo final → gate. Esta página não antecipa PASS remoto. Critérios locais em CHECKS.json; matriz em M1B-GATE.md. Outputs brutos locais ficam em artifacts ignorados; evidências exportadas são sanitizadas e não incluem configuração/credenciais TEST do Playwright. Summarizer só corre depois de terminar o reporter para evitar reutilizar relatório anterior.

O registo final pós-CI será uma nota Git publicada no commit main em refs/notes/m1b-gate, com Repository, Branch, Base/Final Commit, Workflow Run/Result/Jobs, hashes, decisões e riscos. Cópia local em artifacts/M1B-FINAL-GATE.json. Isto evita alterar a árvore aprovada para lhe inserir o seu próprio SHA ou resultado futuro de CI. Consultar com git fetch origin refs/notes/m1b-gate:refs/notes/m1b-gate e git notes --ref=m1b-gate show HEAD. Confirmar sempre headSha/jobs directamente no workflow; nota não substitui execução.

Só após todos os gates remotos PASS: M1B_GATE = PASS; M1C = BLOCKED_PENDING_EXPLICIT_AUTHORIZATION. Se crítico falhar: M1B_GATE = FAIL; M1C = BLOCKED. Não iniciar M1C/M1D/M2 nem declarar M1 completo ou PRODUCTION_READY.
