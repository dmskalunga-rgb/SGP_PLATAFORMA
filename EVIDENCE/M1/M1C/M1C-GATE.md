# M1C — gate

Candidatura local; decisão final depende de commit, push, CI no mesmo SHA e revisão independente ASTRA. Ver CHECKS.json e CI.md. Não declarar PASS enquanto houver controlo crítico pendente/falho.

Controlo obrigatório: regressões M0/M1B; integridade M1A/master; RBAC/ABAC/grants/scope/location/classification/clearance/compartments; AuthorizationPort/default deny; FORCE RLS/USING/WITH CHECK/direct SQL/API; GUC/binding/pool/savepoints; SoD estática/temporal/dinâmica; delegação/maker-checker/replay; escalada/concorrência/auditoria; CI/SAST/SCA/secrets/container scans/SBOM; zero mocks operacionais e HIGH/CRITICAL não resolvidos.

A atestação final exacta do commit encontra-se em `refs/notes/m1c-gate` após publicação, conforme CI.md. O gate falha se qualquer requisito crítico falhar. M1D/M2 continuam bloqueados; PASS não autoriza execução posterior.
