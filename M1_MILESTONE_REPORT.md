# M1 — checkpoint M1A

Nota de publicação: este relatório preserva o checkpoint arquitectural local. O fecho formal e os novos controlos M0/secret scan seguem [PUBLICATION](EVIDENCE/M1/M1A/PUBLICATION.md). O registo final de commit/workflow é ligado ao commit publicado conforme esse procedimento; os contratos congelados permanecem exactos.

Nota de publicação: este relatório preserva o checkpoint arquitectural local. O fecho formal e os novos controlos M0/secret scan seguem [PUBLICATION](EVIDENCE/M1/M1A/PUBLICATION.md). O registo final de commit/workflow é ligado ao commit publicado conforme esse procedimento; os contratos congelados permanecem exactos.

Escopo desta entrega: exclusivamente M1A — SECURITY MODEL & CONTRACT. A decisão e matriz verificáveis estão em [M1A-GATE](EVIDENCE/M1/M1A/M1A-GATE.md). M1 não está concluído; não se declara M1_GATE = PASS nem PRODUCTION_READY. M1B/C/D e M2 não foram implementados.

Foram especificados sete contratos de segurança em docs/security e ADR-007–010 em docs/adr: identidade, autenticação, sessão, contexto por transacção, autorização default deny, grants RBAC com scopes preservados, ABAC, RLS, classificação/compartimentação, delegação, SoD e auditoria. A arquitectura usa PostgreSQL real, sessão opaca revogável e separação de privilégios. Não introduz dados institucionais fictícios.

Base e evidência de M0: [BASELINE](EVIDENCE/M1/M1A/BASELINE.md). DoR, critérios e plano: [M1A-PLAN](docs/requirements/M1A-PLAN.md). Revisão independente: [ASTRA-REVIEW](EVIDENCE/M1/M1A/ASTRA-REVIEW.md). Hashes dos contratos congelados: [FREEZE-MANIFEST](EVIDENCE/M1/M1A/FREEZE-MANIFEST.json). Verificações executadas: [CHECKS](EVIDENCE/M1/M1A/CHECKS.json).

A aprovação M1A significa aprovação técnica documental da arquitectura, não prova de login, RLS ou UI implementados. A aceitação institucional e autorização de execução permanecem com o operador. Paragem obrigatória antes de M1B; nova autorização explícita necessária. Implementação e CI M0 preservadas, verificadas por diff. Nenhum commit ou workflow M1A é inventado; entrega local documental sobre main.

Modelos: elaboração pelo agente principal; revisão crítica L4 independente ASTRA, explicitamente requerida pela ordem M1. Routing do modelo principal não foi alterado; consumo exacto de créditos não disponível. Riscos e obrigações posteriores constam de M1_KNOWN_ISSUES.md.
