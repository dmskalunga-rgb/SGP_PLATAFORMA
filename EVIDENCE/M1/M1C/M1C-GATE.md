# M1C — gate

Candidatura local; decisão final depende de commit, push, CI no mesmo SHA e revisão independente ASTRA. Ver CHECKS.json e CI.md. Não declarar PASS enquanto houver controlo crítico pendente/falho.

Controlo obrigatório: regressões M0/M1B; integridade M1A/master; RBAC/ABAC/grants/scope/location/classification/clearance/compartments; AuthorizationPort/default deny; FORCE RLS/USING/WITH CHECK/direct SQL/API; GUC/binding/pool/savepoints; SoD estática/temporal/dinâmica; delegação/maker-checker/replay; escalada/concorrência/auditoria; CI/SAST/SCA/secrets/container scans/SBOM; zero mocks operacionais e HIGH/CRITICAL não resolvidos.

A atestação final exacta do commit encontra-se em `refs/notes/m1c-gate` após publicação, conforme CI.md. O gate falha se qualquer requisito crítico falhar. M1D/M2 continuam bloqueados; PASS não autoriza execução posterior.

## H1 — estado posterior à revisão independente parcial

ASTRA confirmou `M1C-ASTRA-HIGH-001` no SHA técnico publicado. A prova reproduziu extensão finita → ilimitada sem approval. `M1C_GATE = FAIL` enquanto o finding estiver aberto. A migration forward-only 004 e dois testes focais corrigem localmente o caso; a suite local completa passou 48/48. Novo SHA, nova CI e re-review ASTRA são obrigatórios antes de fechar o finding. Ver HIGH-001-CLEARANCE-TEMPORAL.md e ASTRA-REVIEW.md; a candidatura anterior permanece documentada acima.

Decisão formal após publicação H1: commit técnico [161e246](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/161e246614fb3da8cc3c950f9ed5cf0c42cc301e), [CI 43167843976](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43167843976) PASS nos três jobs, 48 testes PASS, scans PASS, zero mocks operacionais e Master/M1A intactos. **ASTRA re-review: FAIL (não executada; rejeição automática por possível risco de cibersegurança). HIGH-001: OPEN para closure formal. M1C_GATE = FAIL. M1D = BLOCKED. M2 = BLOCKED.** Não declarar PASS com review pendente.

Decisão após `CR-M1C-REVIEW-001`: o revisor substituto independente confirmou H1 corrigido, mas ampliou a revisão aos 40 pontos originais e encontrou `M1C-SUB-MEDIUM-001`, MEDIUM bloqueante na propagação de falhas dos testes de integração pela CI. Parecer focal PASS anterior **substituído** pela adenda final `INDEPENDENT_REVIEW = FAIL`; 39/40 controlos PASS, controlo CI de negative authorization coverage FAIL. `M1C-ASTRA-HIGH-001 = OPEN FOR GOVERNANCE`, `M1C_GATE = FAIL`, M1D/M2 BLOCKED. Histórico de CI e ASTRA acima preservado.
