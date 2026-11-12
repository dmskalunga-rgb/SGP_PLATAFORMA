# M1 — segurança M1C

Master e onze contratos M1A permanecem sujeitos ao guard SHA-256 exacto. Default deny: session/binding privado, versions, permission e scope/location do mesmo effective_grant, clearance, todos os compartimentos, strength e SoD. GUCs apenas propagam atributos derivados; não são credenciais.

Runtimes sem superuser/BYPASSRLS/CREATEDB/CREATEROLE/membership/ownership. Sem INSERT/UPDATE/DELETE/TRUNCATE IAM directo. Funções tipadas têm owners NOLOGIN, search_path fixo, tabelas qualificadas e EXECUTE específico sem PUBLIC/LEAKPROOF. Mutação escolhe lock policy EXCLUSIVE antes dos subjects/sessions ordenados; leituras SHARE, sem upgrade. Audit e mudança são atómicos.

Delegação é configuração explícita, não inferida de permissions. Nenhum self grant ou edição de role própria; role administrativa atribuída não recebe mudança indirecta de permissions. Aprovação revalida maker, sessão original, atributos actuais, policy, payload e checker distinto; consumo único. Dois operadores utilizáveis e permanentes são protegidos contra remoções/agendamentos administrativos previsíveis. Lockout/expiração reais continuam fail-closed.

SAST/SCA/secrets/container/SBOM: resultados medidos em EVIDENCE/M1/M1C/CHECKS.json e CI.md. Nenhum scan pendente significa PASS; nenhum HIGH/CRITICAL não resolvido pode ser aceite pelo gate. Revisão ASTRA independente posterior à CI é obrigatória.

Limites: auth process e migration/DBA são boundaries privilegiados; TLS/CA/provisionamento institucional, configuração de classificação/delegação, capacidade de hardware, recuperação, retenção e cópia externa de audit continuam responsabilidades de deployment. M1D/M2 não iniciados.

Actualização H1: o comparador temporal na migration 004 considera `valid_to=NULL` ilimitado e exige aprovação distinta para qualquer expansão de autoridade não coberta. O payload guarda estado anterior, proposta e versão; execução relê o PostgreSQL sob lock e consumo único. O finding HIGH-001 segue OPEN até scans, CI e re-review ASTRA do novo SHA; nenhum resultado antigo fecha essa condição.

Scans remotos do [run 43167843976](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43167843976) passaram com zero findings SAST/secrets/npm audit e zero vulnerabilidades Trivy HIGH/CRITICAL, quatro SBOM. A revisão automática recusou a tarefa ASTRA por possível risco de cibersegurança; a correcção não recebeu parecer independente. HIGH-001 OPEN para governação; M1C_GATE FAIL.

O revisor substituto independente autorizado por `CR-M1C-REVIEW-001` confirmou o conserto técnico do HIGH-001. A adenda dos 40 pontos encontrou `M1C-SUB-MEDIUM-001`, MEDIUM bloqueante na CI: `npm run test:integration | tee` sem `pipefail`. Uma regressão de segurança pode deixar de reprovar automaticamente o workflow. Parecer independente final FAIL, M1C_GATE FAIL; M1D/M2 BLOCKED.
