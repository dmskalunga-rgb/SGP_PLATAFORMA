# M1 — segurança M1C

Master e onze contratos M1A permanecem sujeitos ao guard SHA-256 exacto. Default deny: session/binding privado, versions, permission e scope/location do mesmo effective_grant, clearance, todos os compartimentos, strength e SoD. GUCs apenas propagam atributos derivados; não são credenciais.

Runtimes sem superuser/BYPASSRLS/CREATEDB/CREATEROLE/membership/ownership. Sem INSERT/UPDATE/DELETE/TRUNCATE IAM directo. Funções tipadas têm owners NOLOGIN, search_path fixo, tabelas qualificadas e EXECUTE específico sem PUBLIC/LEAKPROOF. Mutação escolhe lock policy EXCLUSIVE antes dos subjects/sessions ordenados; leituras SHARE, sem upgrade. Audit e mudança são atómicos.

Delegação é configuração explícita, não inferida de permissions. Nenhum self grant ou edição de role própria; role administrativa atribuída não recebe mudança indirecta de permissions. Aprovação revalida maker, sessão original, atributos actuais, policy, payload e checker distinto; consumo único. Dois operadores utilizáveis e permanentes são protegidos contra remoções/agendamentos administrativos previsíveis. Lockout/expiração reais continuam fail-closed.

SAST/SCA/secrets/container/SBOM: resultados medidos em EVIDENCE/M1/M1C/CHECKS.json e CI.md. Nenhum scan pendente significa PASS; nenhum HIGH/CRITICAL não resolvido pode ser aceite pelo gate. Revisão ASTRA independente posterior à CI é obrigatória.

Limites: auth process e migration/DBA são boundaries privilegiados; TLS/CA/provisionamento institucional, configuração de classificação/delegação, capacidade de hardware, recuperação, retenção e cópia externa de audit continuam responsabilidades de deployment. M1D/M2 não iniciados.
