# Revisão independente — preparação M1 FINAL GATE e CR-SGP-002

**Revisor:** `/root/m1d_publication_review`, contexto independente READ-ONLY.
**Base documental:** `6f2cc119`.
**Manifesto revisto:** `EVIDENCE/M1/FINAL-GATE/DOCUMENTARY-MANIFEST.json`.
**SHA-256:** `cf0f11b0941f2fe4af03ee8a8a45ae8cde2387724a503c8db3b22aeef102b7bd`.

**Recomendação independente actual: `M1_FINAL_GATE = FAIL / BLOCKED`**, enquanto permanecerem os impedimentos de governação e validação descritos abaixo. Trata-se de recomendação para decisão humana, não aprovação ou revogação de gates.

## Integridade e rastreabilidade

Os **13 ficheiros inventariados** correspondem aos respectivos blobs do Git index, sem divergências. Os cinco hashes externos — três ledgers e dois relatórios de scan — também conferem. O manifesto exclui correctamente a si próprio e este parecer para evitar circularidade; a publicação e a CI deverão vincular posteriormente o SHA final.

Não observei alterações a runtime, scripts, testes, workflows, Masters, contratos FROZEN ou migrations 001–006 face ao M1D aprovado.

Verifiquei os blobs, hashes e vínculos target→nota dos quatro registos no ledger histórico M1A/M1B/M1C, incluindo o registo M1C anterior preservado. O ledger CI distingue os runs técnicos, o fecho M1C, as duas CI M1D aprovadas e a falha documental posterior. A decisão humana M1D permanece limitada ao SHA e condições expressamente aprovados.

A tentativa de consulta remota directa das notes nesta revisão falhou por conectividade. A verificação independente incidiu sobre os blobs Git locais e os ledgers preservados; não constitui nova confirmação remota em tempo real.

## Doze cenários críticos do M1

Os 12 cenários lógicos têm nomes de testes, linhas e hashes de fonte correspondentes. Os testes referenciados constam dos dois logs aprovados de integração, cujos hashes conferem.

**G08 demonstra isolamento entre scopes IAM opacos**, conforme o contrato FROZEN RAM/1. Não demonstra departamentos institucionais reais. A futura ligação organização→scope e a sua coerência API/RLS continuam a exigir prova própria em M2. O dossiê apresenta correctamente este limite, sem antecipar M2.

As imprecisões documentais inicialmente identificadas foram corrigidas: G07, G09 e G12 agora descrevem apenas as asserções demonstradas pelas âncoras citadas. Os testes e resultados não foram alterados.

## Proposta CR-SGP-002

A matriz corrigida contém **298 requisitos e 298 IDs únicos**, com zero divergências nos hashes das linhas do Master. Inclui as duas linhas normativas inicialmente omitidas. São 233 tratamentos obrigatórios, 52 simplificações propostas e 13 diferimentos condicionais; nenhum diferimento está marcado como aprovado.

A duplicação inicial de IDs constituía finding documental MEDIUM, **CR2-TRACE-001**, agora corrigido antes da publicação. A precisão das âncoras constitui **FG-EVIDENCE-001**, igualmente corrigido.

As alternativas A/B preservam a cobertura e os gates M2–M7. A explicita M6 básico embutido com owner; B explicita manutenção como quinto módulo e mantém M7 transversal obrigatório. Nenhuma opção é apresentada como autorização de implementação.

Recalculei os totais de dias-pessoa, contingência, fórmulas de custo e cenários de semanas: são aritmeticamente coerentes com as premissas declaradas. Taxas, moeda, capacidade e condições institucionais continuam por aprovar; não há cotação comercial ou compromisso de prazo.

`E2E-SGP-ESS-001` permanece especificação futura, sem execução ou PASS alegado. Preserva negativos, auditoria, RLS, concorrência, rollback e lifecycle TEST.

## Scanner e impedimentos actuais

As quatro detecções históricas conferem com o relatório bruto e respectivo hash. Os dois valores são commits Git existentes, ancestrais da base documental, presentes nas linhas citadas. A alteração acrescenta somente duas excepções exactas à regra Sourcegraph, sem novas exclusões por directório ou redução geral de cobertura. Os relatórios locais worktree/history contêm zero findings.

Permanecem:

- **FG-CI-001 — validação:** publicar o candidato e verificar a CI correspondente. O scan local corrigido não transforma a CI documental histórica falhada em PASS.
- **FG-RISK-001 — governação:** a aceitação de `M1D-RISK-503-001` cobre exclusivamente o encerramento M1D. Não existe extensão automática para M1 FINAL. É necessária disposição humana aplicável ao gate global, encerramento técnico do risco ou decisão sobre evidências/medidas adicionais.
- **Vinculação final:** este parecer revê o inventário pré-publicação; o commit final, a inclusão do parecer e a CI exigem confirmação posterior.

A causa do 503 permanece desconhecida. O prazo original não é reiniciado: 15 dias corridos após formalização válida; 01/12/2026 continua data proposta, sujeita às condições registadas.

## Conclusão

O pacote documental corrigido é adequado para publicação como **preparação de decisão e proposta de planeamento**. Não identifiquei outro finding documental bloqueante no âmbito revisto.

A recomendação do **M1 FINAL permanece FAIL/BLOCKED** enquanto FG-RISK-001 e FG-CI-001 não forem satisfeitos. Os gates anteriores, incluindo o M1D humano condicionado, permanecem preservados.

**M1_FINAL_GATE pendente de decisão humana; M2 bloqueado; CR-SGP-002 apenas proposta; sem autorização de merge ou produção.**

O revisor não editou ficheiros, executou testes, alterou dados, criou commits, publicou alterações ou aprovou gates.
