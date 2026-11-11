# ADR-008 — Authorization Decision Model

Estado: APPROVED/FROZEN M1A. Data: 2026-11-11.

Contexto: RBAC isolado não representa classificação, need-to-know, delegação ou escopo. Decisões divergentes API/DB e revogação concorrente ampliam acesso.

Decisão: ADC/1 default deny. ALLOW exige identidade/sessão válidas, permission exacta e scope/localização do mesmo grant, clearance, todos os compartimentos, strength, SoD, delegação e versões válidas. API avalia cada operação e RLS usa os mesmos predicados versionados por linha/novo estado. Frontend apenas apresenta capacidades. IAM admin não ganha acesso classificado implícito.

Revogação: lock global policy SHARE para pedidos normais, EXCLUSIVE desde início para mutações IAM/auth/sessão; depois subjects ordenados e sessions ordenadas. Proibir upgrades de lock depois de binding normal. Alteração incrementa versões; revogação com commit precede qualquer novo binding válido. Pedidos anteriores podem concluir antes desse commit; timeouts limitam espera. IAM mutations serializadas é tradeoff explícito de correção, a medir antes de optimizar. Auditoria de mutações no mesmo commit; falha nega/rollback.

Alternativas rejeitadas: role-name admin bypass; ABAC ad hoc; permission e scope provenientes de grants diferentes; TTL de cache como única revogação; promessa de revogação retroactiva; auditoria best-effort para mutação sensível.

Boundary de escrita: autoridade IAM é alterada exclusivamente por comandos DB tipados, com actor do binding e revalidação de locks, autorização, delegação, SoD, invariantes, versões e audit. Ambos runtimes sem DML directo IAM. SoD valida sobreposição de vigências presentes/futuras e reavalia activação; identidade administrativa em lockout continua negada, sem bypass para preservar disponibilidade.

Consequências: controlo de concorrência reduz throughput de alterações IAM. Conformidade futura exige matriz comum API/SQL, negações directas, testes concorrentes e SoD de edição de roles. Sem equivalência comprovada, M1C falha. Aceitação M1A apenas de arquitectura.
