# M1 Final Gate — disposição proposta do risco 503

**Estado: PENDING HUMAN DECISION. Não é aceitação nem extensão automática.**

A aceitação e decisão humana M1D aprovam o SHA documental fd993a4, condicionado a M1D-RISK-503-001, e limitam-se expressamente ao encerramento M1D. A causa-raiz continua desconhecida. O dossier inicial M1 Final Gate exige avaliar uma aceitação própria ou extensão de âmbito; a autorização actual permite preparar essa decisão, não tomá-la pelo humano.

## Opções a decidir expressamente

| Opção | Efeito proposto |
|---|---|
|A — Aprovar cobertura específica para M1 Final Gate|Identificar explicitamente o risco, o candidato final e a aceitação no gate global; conservar owner, condições e prazo original. Não autoriza merge, M2 ou produção |
|B — Exigir encerramento técnico antes do gate global|Manter recomendação FAIL/BLOCKED até diagnóstico/correcção, regressões e nova revisão comprovarem a resolução |
|C — Solicitar evidências/medidas adicionais|Definir objecto, responsável, prazo e critérios sem presumir aceitação |

Responsável/autoridade registados em M1D: Kalunga Soares, qualidade declarada Proprietário do Sistema. Qualquer reutilização destas designações no M1 Final exige que a decisão humana o diga expressamente; o agente não preenche uma nova assinatura ou aprovação.

O prazo original é 15 dias corridos depois de formalização válida em M1D; a proposta de 01/12/2026 baseada em 16/11/2026 não é reiniciada por este dossier. Investigar e reportar causa, monitorizar 503/SQLSTATE/latência/timeouts/locks/pools, preservar evidências e reabrir em recorrência relevante ou qualquer indício de perda de auditoria, inconsistência ou falha de segurança.

Impacto: indisponibilidade da consulta pode atrasar investigação/reconstrução; sem evidência associada de perda de eventos, bypass ou efeito de negócio indevido. Probabilidade não quantificada. CIs aprovadas sem recorrência não provam causa resolvida nem desempenho em volume institucional. Não aumentar timeouts, introduzir retries cegos ou flexibilizar testes para obter verde.

Até haver disposição humana aplicável ao M1 Final, este ponto é **impedimento de governação FG-RISK-001**. M1D PASS condicionado e os gates anteriores permanecem preservados; M1 Final Gate não é aprovado e M2 continua BLOCKED.
