# SGP-DISPO — Dossiê de preparação do M1 FINAL GATE

**Estado:** PREPARAÇÃO DOCUMENTAL; NÃO É APROVAÇÃO DO M1_FINAL_GATE  
**Data:** 16/11/2026  
**Repositório:** `dmskalunga-rgb/SGP_PLATAFORMA`  
**Branch de preparação:** `codex/m1d-iam-administration`, PR #1 (Draft, sem merge)  
**Último HEAD verificado antes desta preparação:** `8ccabad82c9678ef01729bd71866e2d4c675b798`  
**SHA M1D expressamente aprovado:** `fd993a4e08d994d357b471f4c56674b0cf979a5f`  
**Autoridade canónica:** `SGP-DISPO-MASTER-v1.1-FROZEN-FINAL.md` e `docs/governance/MASTER-AUTHORITY.md`

## 1. Objectivo e fronteiras

Reunir a cadeia de provas M1A, M1B, M1C e M1D e preparar a decisão humana autónoma do M1 FINAL GATE. Não alterar implementação, contratos FROZEN nem migrations 001–006; não declarar M1 FINAL PASS, não executar merge, não iniciar M2, não executar CR-SGP-002 e não autorizar produção.

Esta preparação documental não constitui uma nova decisão de gate nem substitui a confirmação dos SHA exactos, Git notes de publicação, relatórios brutos, verificações de integridade e revisões independentes.

## 2. Matriz de milestones

| Milestone | Situação documentada | Evidência principal | Verificação adicional do M1 FINAL |
|---|---|---|---|
| M1A — arquitectura de segurança | M1A_GATE PASS, conforme registos existentes | `EVIDENCE/M1/M1A/M1A-GATE.md`, `EVIDENCE/M1/M1A/PUBLICATION.md`, FROZEN manifest/11 artefactos, nota `refs/notes/m1a-publication` | Confirmar nota remota, SHA de publicação, CI e hashes exactos |
| M1B — identidade e sessões | Fecho histórico conforme nota de publicação M1B | `EVIDENCE/M1/M1B/M1B-GATE.md`, `EVIDENCE/M1/M1B/CI.md`, nota `refs/notes/m1b-gate` | Confirmar nota remota, decisão PASS, CI exacta, auth/sessões e regressão |
| M1C — autorização, SoD e RLS | M1C_GATE PASS após fecho HIGH-001/MEDIUM-001 | `EVIDENCE/M1/M1C/CI.md`, `M1_KNOWN_ISSUES.md`, nota `refs/notes/m1c-gate`, CI 43205905235 | Confirmar nota remota e revisão independente, integridade dos controlos corrigidos |
| M1D — administração IAM | **M1D_GATE PASS por decisão humana condicionada** | `EVIDENCE/M1/M1D/M1D-GATE-DECISION-2026-11-16.md`, `EVIDENCE/M1/M1D/FINAL-EVIDENCE-MANIFEST.json`, atestação independente, CI directa 43845885822 e PR 43845886517 | Confirmar vinculação documental posterior, política de autoridade e risco 503 |

**Nota:** nomes e estados históricos de documentos anteriores podem permanecer como snapshots; os gates formais mais recentes prevalecem sem apagar a cronologia.

## 3. Critérios canónicos explícitos do M1-GATE

O Master v1.1 exige **todos os cenários críticos PASS**:

| Cenário | Fonte/ensaio a rastrear | Estado nesta preparação |
|---|---|---|
| Login válido | M1B DB/API/browser TLS | A VALIDAR na matriz final exacta |
| Login inválido | M1B testes negativos | A VALIDAR |
| Lockout | M1B política e testes | A VALIDAR |
| Logout | M1B revogação e browser | A VALIDAR |
| Revogação de sessão | M1B revogação one/all | A VALIDAR |
| Permissão negada | M1C/M1D API/SQL | A VALIDAR |
| Permissão autorizada | M1C/M1D API/SQL | A VALIDAR |
| Negação cross-department | M1C autorização e isolamento | A VALIDAR |
| Negação por classificação | M1C ABAC/classificação | A VALIDAR |
| RLS deny | M1C PostgreSQL FORCE RLS | A VALIDAR |
| RLS allow | M1C PostgreSQL FORCE RLS | A VALIDAR |
| Tentativa de elevação de privilégios | M1C/M1D SoD, maker-checker, IAM | A VALIDAR |

A indicação `A VALIDAR` acima significa **rastreabilidade detalhada pendente neste dossiê**, não falha comprovada do controlo. Não converter em PASS sem evidência específica.

## 4. Evidências transversais a consolidar

1. Integridade de `main`, do SHA M1D aprovado e do PR: base, ancestry, árvore Git, alterações exactas e ausência de merge.
2. Manifestos, blobs e hashes dos 11 artefactos FROZEN M1A e Master v1.1, sem reescrita de migrations 001–006.
3. Notas Git remotas M1A/M1B/M1C, decisões de gate e execuções CI associadas; não presumir confirmação sem consulta.
4. Suite cumulativa M0/M1 com PostgreSQL TEST real, ausência de mocks operacionais e testes negativos API/SQL/browser.
5. CI exact-SHA, scans SAST, Gitleaks com allowlist estrita, npm audit, Trivy/SCA, image gates e quatro SBOM por execução, segundo os âmbitos efectivamente configurados.
6. Pareceres independentes e fecho dos findings HIGH/MEDIUM anteriormente identificados, sem confundir revisão local com submissão GitHub.
7. Rastreamento de limitações institucionais antes de produção: credenciais, TLS, retenção, backups/recuperação, SIEM, parametrização de classes/compartimentos e performance.
8. Inventário de riscos residuais com owner, decisão, prazo, monitorização e gatilhos de reabertura.

## 5. Risco residual principal

**`M1D-RISK-503-001` — investigação ABERTA.**

Aceitação condicionada declarada por Kalunga Soares na qualidade de Proprietário do Sistema, com responsabilidade técnica igualmente assumida. Causa-raiz HTTP 503 ainda desconhecida; a ausência de recorrência nas CIs não equivale à correcção definitiva. Monitorizar 503, SQLSTATE, latência, timeouts, locks e pools; preservar logs sanitizados; reabrir em caso de recorrência relevante, falhas de auditoria ou segurança.

Prazo: **15 dias corridos após formalização válida**. **01/12/2026 é proposta**, sujeita a confirmação das condições de validade e contagem.

A aceitação foi expressamente limitada ao **encerramento do M1D**. O M1 FINAL GATE deve deliberar explicitamente se exige **aceitação própria ou extensão formal da cobertura** deste risco; não presumir extensão automática para M1 FINAL, merge, M2 ou produção.

## 6. Condições de decisão do M1 FINAL GATE

Só propor `M1_FINAL_GATE = PASS` se:
- cada um dos 12 cenários críticos canónicos possuir prova exacta verificável e cumulativa;
- M1A/M1B/M1C/M1D e respectivas notas/atestação estiverem autenticados e coerentes;
- a integridade do código, bases de segurança e migrations publicadas estiver demonstrada;
- os scanners e regressões aplicáveis estiverem concluídos no SHA candidato pertinente;
- todos os findings bloqueantes estiverem encerrados, ou constarem de aceitação de risco competente e aplicável **especificamente ao M1 FINAL**;
- as condições e limites do risco `M1D-RISK-503-001` forem avaliados quanto à sua aplicabilidade no M1 FINAL;
- a autoridade competente emitir **decisão humana expressa** e independente.

Caso haja ausência de provas, declarar `NOT_READY_FOR_GATE_REVIEW` com itens individualizados. NÃO inferir PASS a partir de um gate anterior.

## 7. Próximos passos read-only recomendados

- Verificar Git notes `m1a-publication`, `m1b-gate`, `m1c-gate` contra SHA e CI remotos.
- Construir matriz cenário por cenário, com paths, testes, outputs, IDs e hashes; identificar lacunas reais.
- Confirmar o SHA de HEAD do PR após publicação deste dossiê e CI correspondente, sem atribuir-lhe as CIs anteriores.
- Obter revisão independente exact-SHA, incluindo risco 503 e compatibilidade da aceitação M1D com o gate global.
- Submeter **relatório final somente para decisão humana**, mantendo separadas as autorizações de merge, M2, CR-SGP-002 e produção.

**Estado operacional:** `M1D_GATE = PASS (CONDITIONED)`; `M1_FINAL_GATE = PENDING`; `PR #1 = DRAFT / NO MERGE`; `M2 = BLOCKED`; `CR-SGP-002 = NOT STARTED`; `PRODUCTION = NOT AUTHORIZED`.
