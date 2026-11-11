# M1A — Definition of Ready e plano

Autoridade: master FROZEN intacto; autorização corrente exclusivamente M1A. Base: main no commit de fecho M0-R1; registo completo em EVIDENCE/M1/M1A/BASELINE.md. M1B, M1C, M1D e M2 não estão autorizados nesta execução.

Objectivo: estabilizar e congelar contratos de identidade, sessão, contexto, RBAC/ABAC, RLS, classificação, compartimentos, SoD e auditoria. Actor: engenharia de segurança; revisão crítica independente ASTRA conforme a ordem. Pré-condições: M0 PASS verificável, PostgreSQL 17 e runtime existentes, master com SHA-256 histórico e workspace limpo. Regras: default deny, sem mocks, sem funcionalidades organizacionais/patrimoniais, sem implementação IAM nesta fase.

Dados/API/DB: apenas especificações e contratos, catálogo de operações e modelos lógicos; não criar tabelas, migrations, endpoints, roles DB, cookies ou páginas. Auditoria: especificar integridade, correlação, atomicidade e falhas, sem alegar eventos implementados. Segurança: separar trust boundaries, não tratar GUCs controláveis pelo runtime como identidade confiável, definir isolamento de pool e revogação. Aceitação: sete contratos, quatro ADRs, matriz M1A, revisão independente resolvida sem finding crítico/alto aberto, integridade do master e diff exclusivamente documental. Testes: revisão e verificação documental nesta fase; testes executáveis de IAM ficam planeados e não são reportados como PASS.

Sequência: verificar base; produzir rascunhos; revisão ASTRA independente; corrigir findings; verificar diffs/integridade/coerência; congelar conteúdo por SHA-256; emitir M1A_GATE; parar antes de M1B. Alterar um contrato congelado exige revisão e novo gate; mudanças ao master exigem CR formal.

Modelos: SOL médio recomendado para elaboração; ASTRA disponível para revisão crítica separada, sem delegação mecânica desnecessária. O modelo principal desta sessão não é alterado por ferramenta; não se inventa routing ou consumo. Riscos/dependências: implementação correcta de funções privilegiadas, invalidação transaccional, dimensionamento de hashing e do banco, política institucional de classificações e bootstrap com identidades reais.
