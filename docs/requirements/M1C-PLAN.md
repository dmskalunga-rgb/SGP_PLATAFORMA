# M1C — DoR e plano de execução

Autoridade: master FROZEN e onze contratos M1A, sem alteração. Base: commit [f1b146b](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/f1b146b6fe128adb37271b08e419b1be1b3007c1). Autorização: ordem canónica M1C recebida nesta sessão. M1D/M2 bloqueados.

## Definition of Ready

- Objectivo: enforcement IAM real, por concessão vinculada, ABAC e FORCE RLS, sem mocks operacionais.
- Actores: operador autenticado, segundo operador distinto, sujeito administrado e runtimes SQL sem privilégios de owner.
- Pré-condições: PostgreSQL 17, migrations M0/M1B, sessão opaca válida, política versionada e contratos íntegros.
- Dados: referências técnicas opacas; metadados explícitos de scope, classificação e compartimentos; delegação explícita e aprovações de uso único. Nenhuma entidade organizacional/patrimonial.
- Regras: ADC/1 conjuntivo, validade pelo relógio DB, default deny; nenhuma união cartesiana de grants; nenhum bypass por role ou GUC; self-escalation proibida.
- Segurança: policy SHARE para leitura/EXCLUSIVE desde início para mutação, subjects/sessions ordenados; comandos tipados, owners NOLOGIN, sem DML IAM runtime, search_path fixo, auditoria atómica.
- API: interface AuthorizationPort, listagens paginadas e ID sob RLS; 401/403/404/503; CSRF/origin/TLS M1B preservados. Frontend apenas prova mínima.
- Auditoria: actor derivado do binding, alvo, acção, sessão, request/correlation, versões, decision_id e before/after sem segredos.
- Aceitação: todos os controlos §§63–67 da ordem, incluindo revisão ASTRA independente e CI remota no commit final. Qualquer controlo crítico ausente/falho impede PASS.
- Testes: PostgreSQL real em bases efémeras; matriz API/SQL; SoD estático/temporal/dinâmico; delegação, aprovação, replay, invariantes de dois operadores, adulteração, savepoints, pool e concorrência; regressão M0/M1B e hashes M1A.

## Definition of Done

Implementação e testes verificáveis, zero mocks operacionais, scans sem HIGH/CRITICAL, evidência por controlo, commit/push sem force, CI correspondente e revisão ASTRA. PASS somente após todas as provas. Registar lacunas sem as mascarar como sucesso. Parar antes de M1D/M2.
