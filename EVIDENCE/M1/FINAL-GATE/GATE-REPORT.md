# M1 Final Gate — relatório para decisão humana

Estado: **NOT_READY_FOR_HUMAN_APPROVAL — recomendação M1_FINAL_GATE = FAIL**, enquanto subsistirem os impedimentos abaixo. Esta recomendação não é aprovação ou revogação de qualquer gate anterior.

## Candidato e continuidade

Repositório dmskalunga-rgb/SGP_PLATAFORMA; branch codex/m1d-iam-administration; PR #1 Draft, sem merge. Checkpoint documental de origem: 6f2cc119. M1D foi aprovado expressamente pelo Proprietário do Sistema para `fd993a4e08d994d357b471f4c56674b0cf979a5f`, por acta publicada no commit 8ccabad8. Essa aprovação é condicionada e exclusiva do M1D. O SHA deste novo dossier será identificado pelo commit e pela CI posteriores; não se atribuem a ele resultados históricos.

O preflight encontrou HEAD sincronizado com a branch remota e stage inicialmente vazio. As alterações desta preparação são apenas documentos, inventários e duas excepções exactas de Git metadata no Gitleaks. Não foram alterados runtime, testes, workflows, Masters, contratos FROZEN ou migrations. M0 não foi reiniciado.

## Requisitos e provas

| Controlo | Resultado verificado / limite |
|---|---|
| Autoridade Master v1.1 | Preservada; SHA-256 raw Windows `92de4f9a489a11051f06e7b8eebe61244348dd93ce1b86101fc5f2dd18812ea1`; hash Git no manifesto próprio |
| Contratos M1A | Guard exacto Master histórico + 11 artefactos PASS; nenhuma alteração posterior |
| Migrations 001–006 | Publicadas, preservadas byte a byte em Git face ao M1D aprovado; nenhuma nova migration |
| Gates M1A/B/C | Notas Git publicadas conferidas; MILESTONE-CHAIN.json vincula notas, decisões PASS e CIs; nota M1C FAIL antiga preservada como histórico, não como decisão actual |
| M1D humano | PASS condicionado para fd993a4; acta M1D-GATE-DECISION-2026-11-16.md preservada; investigação 503 aberta |
| 12 cenários críticos §45 | CRITICAL-SCENARIOS.json/.md identificam teste, linha, hash de fonte, asserção e duas execuções aprovadas; cenários lógicos sobrepõem testes |
| Cenário cross-department | PASS no âmbito contratado M1: isolamento entre scopes IAM opacos. Departamentos institucionais reais, hierarquia e ligação aos scopes só pertencem ao M2; não se afirma prova desses dados no M1 |
| Regressão cumulativa aprovada | CIs fd993a4: 43845885822 directa e 43845886517 PR, todos os três jobs SUCCESS; 56 testes normais por execução: 4 unitários + 45 integração PostgreSQL real + 2 browser baseline + 5 TLS/IAM; zero failures/skips/flaky |
| Segurança cumulativa | Nas mesmas CIs: SAST, secret scan, npm audit, SCA, imagens e SBOM aprovados nos âmbitos respectivos; não atribuídos retroactivamente a outro SHA |
| Correspondência histórica | Manifesto M1D verificado no seu próprio snapshot fd993a4; inventário corrente separado, sem reescrever manifestos históricos |
| CI documental de origem | Run 43847723778: Foundation e Container SUCCESS; Source FAIL no secret scan; SAST/SCA posteriores SKIPPED nessa execução, sem declaração falsa de PASS |
| Correcção focal do scanner | Quatro detecções individualizadas, dois Git commits públicos comprovados; apenas duas regexes de valor exacto na regra Sourcegraph, sem excluir directórios ou enfraquecer defaults; SECRET-SCAN-TRIAGE.json |
| Scans locais novos | Gitleaks worktree e histórico: execução concluída com zero findings; relatórios raw em artifacts/m1-final-{worktree,history}-current.json; submissão remota deste dossier ainda a verificar separadamente |
| Revisão independente | Solicitada sobre estes dossiers; conclusão deverá constar em INDEPENDENT-REVIEW.md ou permanecer pendência explícita |

Os testes funcionais aprovados não foram repetidos localmente: o código correspondente permanece inalterado. Uma nova CI documental, quando publicada, não substitui a decisão humana nem resolve por si a causa 503.

## Findings e risco residual

- **FG-CI-001 — bloqueante de validação:** CI do novo candidato documental deve demonstrar a resolução do secret scan e os restantes controlos. A falha histórica permanece registada, nunca convertida em PASS por editar um relatório.
- **FG-RISK-001 — bloqueante de governação:** a aceitação M1D-RISK-503-001 limita-se ao encerramento M1D. Não há extensão automática para o M1 Final. Submeter a proposta RISK-503-SCOPE-PROPOSAL.md à decisão humana competente.
- **FG-REVIEW-001 — pendência de aceitação:** obter conclusão independente referente ao inventário final; a atestação histórica M1D não equivale a revisão deste novo dossier.
- **CR2-TRACE-001 — MEDIUM documental corrigido antes de publicação:** revisão independente identificou IDs duplicados na proposta; regenerados por tipo de origem, 298 IDs únicos, incluindo duas linhas normativas antes só cobertas pelos controlos comuns, com linhas/hashes de origem preservados. Não afecta código ou contratos.
- **FG-EVIDENCE-001 — precisão documental corrigida:** asserções dos cenários G07/G09/G12 limitadas ao que as âncoras citadas realmente demonstram; sem alterar testes ou resultados.

503: impacto potencial é indisponibilidade da consulta ampla, atrasando investigação/reconstrução. A probabilidade não é quantificável. Não há evidência apresentada de perda de eventos ou bypass relacionado; isso não prova ausência de risco. Causa-raiz desconhecida; duas CIs sem recorrência não a encerram. Monitorizar frequência, SQLSTATE, latência, timeouts, locks e pools, com diagnóstico sanitizado e evidências preservadas. Reabrir perante recorrência relevante, inconsistência, perda de auditoria ou indício de segurança. Responsável técnico e autoridade declarada: Kalunga Soares, Proprietário do Sistema. Prazo original: 15 dias corridos da formalização válida, proposta de limite 01/12/2026, sem reinício pela presente preparação. Sem produção autorizada.

## Decisões preparadas

1. Dispor expressamente sobre cobertura do risco 503 no M1 Final, exigir encerramento técnico ou pedir medidas adicionais.
2. Avaliar CI e parecer independente do candidato documental final.
3. Decidir M1_FINAL_GATE separadamente; o agente recomenda FAIL enquanto os impedimentos não forem satisfeitos.
4. Decidir a proposta CR-SGP-002 separadamente; A/B não alteram por si o Master ou os gates M2–M7.

**M1_FINAL_GATE = PENDING HUMAN DECISION. M2 = BLOCKED. CR-SGP-002 = PROPOSAL ONLY.** Não se autoriza merge, implementação patrimonial ou produção.
