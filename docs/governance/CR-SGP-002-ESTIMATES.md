# CR-SGP-002 — esforço, custos e calendário paramétricos

Estado: estimativa ROM de planeamento, não preço contratual, compromisso de prazo ou autorização. Não foram fornecidas moeda, taxa/hora e capacidade aprovadas. Base: requisitos M2–M7 da matriz e controlos completos do Master; sem medição de velocidade da equipa. Recalibrar após DoR e primeira entrega autorizada. Confiança inicial baixa; factores institucionais podem ampliar os intervalos.

## Comparação a cobertura equivalente

Dia-pessoa (DP) = 8 horas líquidas de trabalho, hipótese de cálculo a validar. Esforço de módulo inclui análise, UI/API/DB, regras, testes focais, documentação e evidência. A linha comum acrescenta integração E2E, revisão transversal e preparação de gates, evitando contar novamente os mesmos testes focais.

| Pacote comum | DP mínimo | DP máximo |
|---|---:|---:|
| M2 organização/localizações/referenciais |18|28|
| M3 entrada/cadastro/documentos/QR |26|40|
| M4 afectação/movimento/custódia/workflows |24|36|
| M5 inventário/reconciliação/mobile online |24|38|
| M6 manutenção/ciclo de vida básicos indispensáveis |20|32|
| M7 relatórios/painel/exports autorizados |20|32|
| DoR/ADRs e integração/segurança/evidência transversal |18|28|
| **Núcleo comum** |**150**|**234**|

| Organização | Ajuste de coordenação/superfícies | Total base DP | Contingência de planeamento 25% | Total provisionado DP |
|---|---:|---:|---:|---:|
| A: relatórios como 5.º, M6 embutido A2/A3 |10–18|160–252|40–63|**200–315**|
| B: manutenção como 5.º, M7 transversal |8–14|158–248|40–62 (arredondado)|**198–310**|

Os ajustes são hipóteses de engenharia para explicitar coordenação/UI/contratos; não são produtividade observada. A diferença pequena não sustenta uma decisão financeira isolada. Eliminar rótulos de módulos não elimina manutenção ou relatórios exigidos. A vantagem B depende de manter owner/backlog M7; A depende de disciplinar o acoplamento M6.

## Opções condicionais fora deste núcleo estimado

| Opção a decidir no DoR/CR | Acréscimo ROM DP antes de contingência | Condição |
|---|---:|---|
| Offline/sincronização segura e conflitos |20–35|Incluir se tecnicamente necessário no processo homologado; não pode ser dispensado apenas por custo |
| Regras financeiras avançadas homologadas |12–24|Depreciação/reavaliação/imparidade conforme aplicabilidade; sem inventar política contabilística |
| Intangíveis/licenças/subscrições |8–16|Activação conforme aplicabilidade institucional e Master |
| Automação/analytics avançados adicionais |12–24|Não substitui SLA básico, tendências/relatórios e notificações reais já incluídos |

Não somar opções sem análise de sobreposição e aprovação. Funcionalidade considerada obrigatória após DoR deve ser incorporada no âmbito e orçamento antes do gate; a estimativa essencial não dá autorização para declarar o Master cumprido com ela em falta. Integrações institucionais, hardening/aceitação, formação final e produção M8–M10 têm orçamento próprio e não estão dispensados.

## Custos por fórmula

Se `Rh` for taxa/hora média aprovada, na moeda escolhida:

- A: custo de trabalho provisionado = **1600×Rh a 2520×Rh**.
- B: custo de trabalho provisionado = **1584×Rh a 2480×Rh**.
- Se houver taxas por perfil: `C_trabalho = soma(horas_perfil × taxa_perfil)`; uma composição inicial a validar é 60% desenvolvimento, 25% QA/testes e 15% arquitectura/segurança.
- `C_total = C_trabalho + infraestrutura incremental aprovada + IA/CI/licenças efectivamente contratadas + serviços externos aprovados + tributos aplicáveis`.

As parcelas adicionais não têm preço presumido. Reutilização on-premises depende de capacidade verificada; não equivale a infraestrutura gratuita. IA não elimina revisão humana, segurança ou testes. Tarifas, câmbio e contratos devem ser obtidos das fontes/fornecedores aprovados no momento da decisão; este dossier não fornece cotação de mercado.

## Calendário por capacidade

`Semanas_execução = teto(DP_provisionados / (5 × FTE × disponibilidade))`.

Adicionar `Tgates` para decisões/validações externas, sem converter espera em esforço cobrado automaticamente. Como cenário ilustrativo, usar disponibilidade 0,75 e espera acumulada 2–6 semanas; ambos os parâmetros exigem confirmação. Milestones continuam sequenciais e autorizações não se antecipam.

| Cenário | A, incluindo espera hipotética | B, incluindo espera hipotética |
|---|---|---|
|1 FTE, disponibilidade75% |56–90 semanas|55–89 semanas|
|2 FTE, disponibilidade75% |29–48 semanas|29–48 semanas|
|3 FTE, disponibilidade75% |20–34 semanas|20–34 semanas|

Estes valores são limites por capacidade agregada, sujeitos ao caminho crítico e à disponibilidade de especialistas; dividir o esforço por pessoas não permite implementar milestones ainda bloqueados. A ordem é M2→gate→M3→gate→M4→gate→M5→gate→M6→gate→M7. D0 só existe após M1 Final Gate humano, decisão do CR, DoR e autorização explícita M2.

Não há data contratual ou de produção. Dados institucionais, política financeira, acesso à infraestrutura, volume/carga, offline e decisões de segurança são riscos de calendário. O orçamento definitivo exige validação das premissas, opções e taxas pelo humano.
