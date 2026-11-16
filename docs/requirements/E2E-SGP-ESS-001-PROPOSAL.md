# E2E-SGP-ESS-001 — proposta de teste transversal essencial

**Estado:** especificação de aceitação futura, NÃO IMPLEMENTADA / NÃO EXECUTADA neste checkpoint. Não é evidência de PASS M2–M7. Preserva os gates específicos do Master e a aceitação institucional M9.

Objectivo: reconstruir em UI/API/PostgreSQL/storage reais a vida de um activo e as decisões de segurança, nas alternativas A e B. O agrupamento de menus não altera a sequência, os owners de escrita nem os oráculos.

## Preconditions futuras

M1 Final Gate humano, CR aprovado, autorizações e implementações M2–M7 pertinentes; ambiente TEST descartável e inequívoco; dois operadores distintos com autoridade e utilizadores de scopes diferentes; classes/compartimentos e delegação parametrizados segundo DoR. Fixtures apenas TEST, identificáveis e com lifecycle; nenhum dado institucional inventado no produto.

A criação das unidades, locais, activos e restantes dados deste teste só ocorrerá após autorização dos respectivos milestones. Não criar agora entidades, rotas, migrations, seeds patrimoniais ou scripts de execução do cenário.

## Fluxo proposto e oráculos

| Passo | Acção real futura | Oráculo e evidência esperados |
|---|---|---|
|ESS01|Login e validação do contexto dos actores|Sessão real, capacidades exactas, IDs/correlação; credenciais/tokens nunca nos artefactos |
|ESS02|Criar estrutura/localização/armazém/centro de custo e referenciais autorizados M2|PostgreSQL persistente, sem ciclos/duplicados/períodos inválidos; ligação de scopes preserva M1; audit e consulta paginada |
|ESS03|Registar origem de aquisição/entrada e fornecedor/documento|Origem e documento separados, storage controlado e metadata/hash, leitura autorizada |
|ESS04|Receber, validar e incorporar activo|Transacção/constraints; internal UUID e número humano distintos; categoria/modelo/serial/classificação e valor base quando aplicável |
|ESS05|Associar QR/barcode e consultar activo por UI/API|Referência segura sem dados sensíveis no código; dados iguais à fonte DB, sem KPI ou estado fabricado |
|ESS06|Afectar activo e registar custódia/responsabilidade|Organização, localização, custódia e propriedade permanecem conceitos distintos; termo/histórico real |
|ESS07|Solicitar transferência e obter checker distinto|SoD, delegação, scope/classificação/compartimentos; payload/estado/validade vinculados, sem auto-aprovação |
|ESS08|Entregar e confirmar recepção; incluir empréstimo/devolução e reserva básicos|Localização/custódia actualizadas transaccionalmente; cadeia imutável; expiração/conflito/reserva não equivale a entrega |
|ESS09|Executar campanha de inventário por mobile web online, QR/barcode e contagem manual|Persistência de contagem autorizada; divergência de localização/custódia/condição e item ausente/inesperado detectados |
|ESS10|Reconciliar, aprovar e encerrar inventário|Decisão/evidência preservadas; aprovação distinta quando exigida; relatório reconcilia com DB |
|ESS11|Reportar avaria, abrir ordem, avaliar garantia/prestador/SLA, consumir peça, registar custo e retornar a serviço|Movimento de stock real, eventos/timestamps e custos; lifecycle íntegro; elegibilidade de garantia e disponibilidade verificáveis |
|ESS12|Propor/aprovar abate ou alienação e consultar história|Workflow autorizado; activo não é apagado; estado final e histórico recuperáveis |
|ESS13|Consultar painéis/relatórios/tendências e exports limitados por scope|Agregações SQL reais; totais reconciliam; paginação/limites; export autorizado/auditado sem fuga de classificação |
|ESS14|Reconstruir a cadeia completa por auditor independente|Actor, alvo, acção, before/after aplicável, motivo, decisão, tempo, request/correlation/approval; nenhum segredo; todos eventos recuperáveis |

## Negativos e falhas obrigatórios

1. Actor de outra unidade/scoped grant não lê/altera/conta/exporta o activo. Comparar API e SQL/RLS; não usar só visibilidade do frontend.
2. Clearance insuficiente ou compartimento ausente oculta dados e nega operações; revogação passa a valer segundo o contrato M1.
3. Maker=checker, auto-elevação, payload/approval adulterados, approval expirada/replay e entitlement revogado são negados e auditados conforme o canal aplicável.
4. Duplicação de serial/número proibida; hierarquia cíclica, referências/períodos inválidos e reserva conflituosa rejeitados.
5. Repetição do mesmo pedido conserva idempotência prevista; dois movimentos concorrentes incompatíveis não produzem dois estados válidos.
6. Falha de append de auditoria ou falha intermédia deliberada em TEST impede efeito protegido e prova rollback. Denial audit preserva contexto sem inventar IDs.
7. Acesso SQL directo pelos runtimes não contorna os executores/constraints/RLS; FLAG/SET ROLE/GUC/body claims não fornecem autoridade.
8. Dependência indisponível retorna erro sanitizado; nunca sucesso fictício, dados de demonstração ou retry cego para ocultar falha.
9. Lifecycle TEST encerra app/pools, comprova zero conexões e remove recursos próprios sem destruir dados externos, também perante falha do teste.

## Ramos condicionais

- ESS-OFFLINE: se offline for requerido, captura mínima protegida, validade, sincronização autenticada/idempotente e conflito sem sobrescrita silenciosa. Não dispensar por marcar o ramo como “diferido” antes da decisão do DoR/CR.
- ESS-FIN: se valorização avançada for habilitada, aplicar apenas regras homologadas, conferir totais, períodos e auditoria; não inventar política contabilística.
- ESS-INT: se intangíveis/licenças forem aplicáveis, testar lifecycle próprio sem quebrar o modelo comum.

## Pacote de provas futuro e aceitação

Proposta de outputs: versão dos contratos/código/migrations, matriz de actores/permissions, IDs TEST, resultados API/SQL/browser, eventos correlacionados, hashes de documentos/exports, relatórios de reconciliação, métricas/carga aprovadas, scans/SBOM, manifesto e teardown. Evitar screenshots/trace contendo palavras-passe ou cookies; guardar apenas dados sanitizados autorizados.

PASS apenas com os passos e negativos aplicáveis executados, oráculos cumpridos, zero falhas/skips injustificados e revisão independente segundo o gate responsável. Qualquer condição institucional indefinida permanece pendente, sem inferência de PASS. A proposta não altera ou substitui DoR/DoD, M2–M7-GATE, M9/UAT/SAT, backups/restore ou autorização de produção.
