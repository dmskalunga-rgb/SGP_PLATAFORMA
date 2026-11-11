# M1C — comandos e evidências

- Estado inicial: git status --short, log e remote; main limpo na base M1B.
- DoR antes da migration: docs/requirements/M1C-PLAN.md; leitura integral da autorização canónica M1C.
- npm run build / npm run lint / npm run typecheck: PASS.
- node scripts/check-frozen.mjs: master + 11 FROZEN exactos, PASS.
- npm run test:policy: operationalFindings=0.
- scripts/local-tests.ps1: PostgreSQL 17 real descartável, migrations 001–003, 4 unit + 36 integration + 2 browser M0 + 4 TLS browser; exit 0. Logs e hashes em CHECKS.json.
- npm audit --json: zero vulnerabilidades de todas as severidades.
- Semgrep 1.185.0, cinco regras, apps + scripts/migrate.mjs, ficheiros novos incluídos: zero findings.
- Gitleaks 8.30.1 dir: zero; git --log-opts=main: zero. Scan all-refs encontrou quatro hashes públicos nas Git notes M1A/M1B, verificados individualmente, sem segredo/alerta não resolvido; SECRET-SCAN.json conserva a classificação.
- Observou-se um timeout de auditoria sob carga durante uma execução intermédia; consulta de permission exacta optimizada mantendo grants vinculados e timeouts. Suite M1C e regressão completa repetidas com sucesso após correcção.
- git diff --check e guard FROZEN antes do commit. Publicação sem force, CI por SHA e revisão ASTRA independente posteriores; resultado final na atestação descrita em CI.md.

Não registar credenciais, passwords, tokens ou ficheiros .test-secrets. Nenhum M1D/M2 executado.
