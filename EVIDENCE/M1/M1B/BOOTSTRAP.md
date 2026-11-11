# Bootstrap controlado

Comando real: scripts/bootstrap-identity.mjs. Requer BOOTSTRAP_DATABASE_URL de deployment e duas identidades reais distintas por stdin protegido; schemas/Argon2/policy validados, nenhum default de username/password. Procedimento detalhado: docs/operations/M1B-IDENTITY-RUNBOOK.md. Nada no comando cria inventário, departamento ou identidade operacional fictícia.

SQL iam.bootstrap executa sob lock exclusivo e só em estado vazio/bootstrap_completed=false; insere as duas identities/credentials/grants mínimos e BOOTSTRAP_COMPLETED atomicamente. Segunda execução recusa. app_runtime/auth_runtime não têm EXECUTE; apenas deployment pode invocar. Falha não deixa identidade parcial. Não há override ou recovery automático. Duas identidades iniciais não conferem clearance máximo ou compartments nem permitem self-approval de concessões futuras.

E2E TEST executa o comando real com dados efémeros identificados TEST, depois login/logout real e replay negado. Teste DB recusa segunda execução e chamada por runtime. Bases/containers de fixtures são destruídos. Evidência não inclui password/hash/token real ou TEST.
