# Revisão crítica independente M1A

Data: 2026-11-11. Instância separada: /root/m1a_astra_review, sem herdar a conversa (fork_turns=none). Modelo solicitado explicitamente na ferramenta: gpt-6-astra, reasoning_effort=high, conforme autorização do utilizador. A ferramenta criou a instância; build/ID interno não foi exposto pelo contexto do revisor e não é inventado. O revisor leu integralmente o master, confirmou SHA-256 e leu a ordem M1, sete contratos, quatro ADRs e DoR/plano. Não editou ficheiros nem executou IAM.

## Revisão inicial — REQUEST_CHANGES

Decisão inicial: REQUEST_CHANGES; avaliação inicial M1A_GATE = FAIL até correcção, antes do gate formal. Uma finding alta e três médias foram identificadas. O resultado inicial é preservado; não houve aprovação ignorando findings.

| ID | Severidade | Finding original | Correcção aplicada pelo autor |
|---|---|---|---|
| AR-01 | Alta | Escritas IAM podiam depender de RLS/API sem negar explicitamente DML directo ou obrigar executor com locks/SoD/audit | RLS/1 enumera relações sem DML directo app/auth; executor NOLOGIN tipado por operação revalida actor do binding, autorização, locks, delegação, SoD, versões e audit; bootstrap/auth separados; ADC/RAM/ADR008/010 sincronizados; RLS-011 planeado |
| AR-02 | Média | Concessões futuras incompatíveis podiam sobrepor-se sem avaliação temporal explícita | SOD/1 define intervalos UTC [from,to), valida sobreposição futura, activação e decisão; erros/conflitos negam; SOD-006 planeado; indisponibilidade administrativa não cria bypass |
| AR-03 | Média | finish eliminava prova do bind anterior e permitia sequência bind(A)/finish/bind(B) no mesmo xid | finish conserva marcador CLOSED sem autoridade e rejeita rebind; savepoints/rollback delimitados por efeitos sobreviventes; RLS-012 e ADR010 sincronizados |
| AR-04 | Média | TTL de binding, statement e idle timeout não limitavam transacção com vários statements curtos | SCC exige transaction_timeout PostgreSQL17 15s, deadline wrapper, cancel/rollback e descarte de client incerto; RLS-012 cobre libertação de locks; risco de settings editáveis reconhecido |

## Re-review independente — APPROVE

Após reler os ficheiros corrigidos, o revisor declarou: **APPROVE — arquitectura M1A**. AR-01, AR-02, AR-03 e AR-04 = CLOSED, sem nova contradição bloqueante. SCC/1, ADC/1, RAM/1, RLS/1, SES/1, CLS/1, SOD/1 e ADR007–010 APPROVED para arquitectura M1A. Default deny confirmado documentalmente e sem funcionalidade M2 nos artefactos revistos.

A aprovação não declara gate formal executado, IAM implementado ou testes operacionais. Persistem riscos de implementação dos executores/helpers, contenção dos locks, calibração Argon2, classificações/bootstrap/recuperação institucionais e demonstração futura API/SQL. RLS não protege contra DBA/superuser ou comprometimento do auth service.

O revisor entregou hashes dos ficheiros ainda DRAFT/PROPOSED. Estes são preservados em REVIEWED-DRAFT-HASHES.json. O freeze apenas troca os estados documentais para FROZEN/APPROVED e conserva semântica; FREEZE-MANIFEST.json contém hashes finais e CHECKS.json comprova equivalência normalizando apenas essas palavras. Qualquer alteração semântica exige nova revisão/gate.

M1B continua dependente de autorização explícita; M2 permanece bloqueado. Decisão formal final e evidências objectivas: M1A-GATE.md.
