# M1A — publicação e fecho formal

Autoridade: ordem de publicação M1A recebida em 2026-11-11. Execução limitada a validar/publicar os artefactos aprovados. Não redesenhar segurança, não alterar os onze ficheiros FROZEN, não iniciar M1B. Os relatórios/checks anteriores permanecem evidência histórica do checkpoint local.

Repository: https://github.com/dmskalunga-rgb/SGP_PLATAFORMA . Branch: main. Base de publicação: commit ligado em BASELINE.md. Master SHA-256 obrigatório: `7CDE06093C1A3F0D7EF7C463BC7EE08CB4FCAC48F4B149D377166C0FF171A667`.

## Controlos antes do commit

Comandos de inventário executados: git status; git diff; git diff --cached; git log --oneline --decorate -10. Só artefactos M1A e evidência associada são candidatos. Nenhuma alteração ao runtime, migrations, API, UI, dependências, infraestrutura ou workflow M0.

Validar SHA-256 bruto dos sete contratos e quatro ADRs contra FREEZE-MANIFEST.json e reconstruir hashes reviewed-draft trocando apenas estados. Repetir comparação no index e no blob do commit, sem normalizar o conteúdo congelado. Master bruto e blob histórico também têm de coincidir. Validar presença de todos os relatórios/evidências e referências Markdown locais.

Regressão: npm run lint; npm run typecheck; npm run build; npm run test:policy; scripts/local-tests.ps1 (suite existente, PostgreSQL real descartável, migration, unit/integration e browser com runtime DB sem privilégios elevados). Não criar schemas/tabelas IAM M1. O script M0 limpa o seu container TEST sem tocar nos serviços externos existentes.

Resultados e logs sanitizados de regressão: PUBLICATION-REGRESSION.json. Secret scan do candidato usa a imagem/configuração já aprovadas:

```powershell
docker run --rm --mount 'type=bind,source=D:\SGP_PLATAFORMA,target=/src' ghcr.io/gitleaks/gitleaks:v8.30.1 dir /src --config /src/.gitleaks.toml --redact --report-format json --report-path /src/artifacts/gitleaks-m1a-publication.json
```

Resultado versionado: PUBLICATION-SECRET-SCAN.json; exige []. Sem mudar allowlists. PREPUBLICATION-CHECKS.json regista integridade, scope, presença e resultados. Depois: git add .; git status; git diff --cached; git commit -m "docs(m1a): freeze security architecture and authorization contracts"; git push origin main, sem force.

## Evidência remota e registo final

Só declarar M1A_PUBLICATION_GATE = PASS depois de push confirmado e CI do SHA exacto concluída: Foundation tests, Source security and SBOM, Container security, todos success. Qualquer controlo crítico pendente/falhado mantém publicação sem PASS e M1B bloqueado.

O SHA de um commit e o resultado da sua CI só existem depois de a sua árvore estar fechada. Para registar ambos sem alterar a árvore validada nem criar uma sequência infinita de commits de evidência, o registo final é uma **nota Git publicada** no próprio commit, em refs/notes/m1a-publication. A nota contém Repository, Branch, M1A Final Commit SHA, Workflow Run ID/URL/Result, Master SHA-256, ASTRA Review Result, regressão, hashes congelados e decisões dos gates. Uma cópia JSON local fica em artifacts/M1A-PUBLICATION-FINAL.json (ignorada, sem secrets). Esta página é o índice versionado do registo pós-CI; não é uma declaração antecipada de sucesso.

Obter/verificar o registo final:

```powershell
git fetch origin refs/notes/m1a-publication:refs/notes/m1a-publication
git notes --ref=m1a-publication show HEAD
git rev-parse HEAD
git ls-remote origin refs/heads/main refs/notes/m1a-publication
```

A nota é publicada sem force. A presença de uma nota não substitui confirmação do headSha e dos jobs na API/URL do workflow. Nenhuma mudança aos contratos ou implementação ocorre após a CI; se ocorrer alteração posterior, o gate exige validação do novo SHA.

ASTRA: APPROVE documental após AR-01–04 CLOSED, conforme ASTRA-REVIEW.md; nenhuma nova revisão arquitectural é alegada. Zero mocks operacionais. Não há IAM M1 implementado nem declaração PRODUCTION_READY. Mesmo após publicação PASS: M1A_GATE = PASS; M1B = BLOCKED_PENDING_EXPLICIT_AUTHORIZATION; STOP. M2 permanece bloqueado.
