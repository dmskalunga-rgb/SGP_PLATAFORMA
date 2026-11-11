# M1B — riscos residuais e limites

Gate remoto e vulnerabilidades: registo final em EVIDENCE/M1/M1B/CI.md. Nenhum HIGH/CRITICAL aceite silenciosamente; scans pendentes não são PASS.

| Item | Tratamento/limite |
|---|---|
| auth_runtime/processo auth é boundary confiável | Pools/grants separados; comprometimento total não neutralizado por RLS |
| Contenção locks IAM | Corrida/deadline15s testados; dimensionar hardware sem reduzir coerência |
| Argon2/memória | DEV e CI medem; reservar64MiB/hash, concorrência2/processo; validar alvo institucional |
| Lista local de passwords pequena | Bloqueio funcional; ampliar corpus controlado antes de produção |
| Ataque dirigido pode causar lock temporário | 15min sem extensão, quotas IP/nonce/hash; rede/monitorização institucionais |
| TLS/CA/secrets/operadores | Templates/validação; sem deployment produção alegado; provisionamento externo obrigatório |
| Recuperação/retenção/cópia audit/SIEM | Sem backdoor/reset remoto; procedimento e sign-off institucional posteriores |
| Avisos Fastify/NO_COLOR | Depreciação, sem falha; não classificados como vulnerabilidade HIGH/CRITICAL |
| Main protection herdada M0 inactiva | Não alterada; push autorizado sem force e CI obrigatória |

M1C/D/M2 bloqueados. RLS de negócio/classificação/compartimentos/SoD completo/admin entitlements são subfases não autorizadas, sem mocks a mascará-las. Não declarar M1 completo nem PRODUCTION_READY.
