# M1C — gate

Candidatura local; decisão final depende de commit, push, CI no mesmo SHA e revisão independente ASTRA. Ver CHECKS.json e CI.md. Não declarar PASS enquanto houver controlo crítico pendente/falho.

Controlo obrigatório: regressões M0/M1B; integridade M1A/master; RBAC/ABAC/grants/scope/location/classification/clearance/compartments; AuthorizationPort/default deny; FORCE RLS/USING/WITH CHECK/direct SQL/API; GUC/binding/pool/savepoints; SoD estática/temporal/dinâmica; delegação/maker-checker/replay; escalada/concorrência/auditoria; CI/SAST/SCA/secrets/container scans/SBOM; zero mocks operacionais e HIGH/CRITICAL não resolvidos.

A atestação final exacta do commit encontra-se em `refs/notes/m1c-gate` após publicação, conforme CI.md. O gate falha se qualquer requisito crítico falhar. M1D/M2 continuam bloqueados; PASS não autoriza execução posterior.

## H1 — estado posterior à revisão independente parcial

ASTRA confirmou `M1C-ASTRA-HIGH-001` no SHA técnico publicado. A prova reproduziu extensão finita → ilimitada sem approval. `M1C_GATE = FAIL` enquanto o finding estiver aberto. A migration forward-only 004 e dois testes focais corrigem localmente o caso; a suite local completa passou 48/48. Novo SHA, nova CI e re-review ASTRA são obrigatórios antes de fechar o finding. Ver HIGH-001-CLEARANCE-TEMPORAL.md e ASTRA-REVIEW.md; a candidatura anterior permanece documentada acima.
