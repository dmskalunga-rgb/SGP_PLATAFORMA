# M0-R1 — relatório formal do milestone

M0_GATE = PASS

Initial M0 Gate: FAIL (histórico preservado em EVIDENCE/M0-EXECUTION.md). M0-R1 remediation: executed. Final M0-R1 Gate: PASS.

Estado: GATE_PASSED. A execução termina no M0. M1 = BLOCKED_PENDING_EXPLICIT_AUTHORIZATION até nova autorização explícita, após revisão humana das evidências. Não se declara PRODUCTION_READY.

## Resumo técnico

Foi preservado o monorepo React/Vite, Fastify/TypeScript strict e PostgreSQL. A remediação acrescentou testes reais de configuração, migrations, API e browser; integridade transaccional/checksum das migrations; configuração externa do backend; estados de disponibilidade e retry reais; imagens sem privilégios e sem ferramentas de desenvolvimento desnecessárias; scans obrigatórios e SBOMs; histórico Git e CI remota no repositório oficial.

A versão técnica validada é o commit [d966c61](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/d966c61ec280cf0aeb1e6fe739771698e98ab623), branch main. O workflow [M0 Foundation Gate — run 43006790217](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43006790217) passou os três jobs em 11/11/2026, concluindo às 11:50:46 de África/Luanda. Os relatórios e artefactos preservados nesta entrega documentam esse commit; a publicação de evidências posterior repete os mesmos gates.

## Matriz final do gate

| Critério obrigatório | Decisão | Evidência verificável |
|---|---|---|
| Build | PASS | Foundation tests / npm run build |
| Lint | PASS | Foundation tests / npm run lint |
| Typecheck | PASS | TypeScript strict |
| API starts | PASS | Playwright webServer e smoke de imagem |
| Web starts | PASS | Browser e Nginx |
| PostgreSQL starts | PASS | Imagem real sgp-postgres:m0 |
| Migration | PASS | Runner real em PostgreSQL |
| Migration idempotency | PASS | Teste de persistência/timestamp |
| Checksum drift rejection | PASS | Teste de checksum alterado |
| DDL rollback | PASS | Falha deliberada com rollback de DDL e tracking |
| Health live | PASS | HTTP 200 com e sem banco |
| Health ready | PASS | HTTP 200 com banco/schema prontos |
| PostgreSQL outage readiness | PASS | HTTP 503 após parar banco |
| Unit tests | PASS | 2 PASS |
| Integration tests | PASS | 4 PASS com PostgreSQL real |
| Browser tests | PASS | 2 PASS; zero flaky/skip |
| npm audit | PASS | Zero vulnerabilidades em todos os níveis |
| Mock policy | PASS | Zero mocks operacionais; referências classificadas |
| Secret scan — source | PASS | Gitleaks candidato final: zero segredos |
| Secret scan — history | PASS | Gitleaks histórico completo: zero segredos |
| SAST | PASS | Semgrep: zero findings e erros |
| SCA | PASS | Trivy filesystem: zero HIGH/CRITICAL |
| API image scan | PASS | Trivy: zero HIGH/CRITICAL |
| Web image scan | PASS | Trivy: zero HIGH/CRITICAL |
| PostgreSQL image scan | PASS | Trivy: zero HIGH/CRITICAL |
| Container non-root | PASS | UID DB/API/web = 70/1000/101 |
| Container read-only runtime | PASS | Smoke com read-only root |
| No development tooling in runtime | PASS | API sem npm/TypeScript/Vite/ESLint |
| SBOM dependencies | PASS | CycloneDX, 59 componentes |
| SBOM API image | PASS | CycloneDX, 99 componentes |
| SBOM web image | PASS | CycloneDX, 71 componentes |
| SBOM PostgreSQL image | PASS | CycloneDX, 46 componentes |
| Remote CI | PASS | Três jobs success; CI repetida na publicação |
| Canonical document integrity | PASS | SHA-256 histórico igual no blob Git e ficheiro |
| Required documentation | PASS | Artefactos obrigatórios e evidência presentes |

## Decisões e riscos residuais

ADR-001 mantém a stack canónica, testes com PostgreSQL real, proxy same-origin, migrations transaccionais e imagens separadas. As sete ocorrências MODERATE foram FIXED, sem aceitação de risco. Bibliotecas vulneráveis de Nginx/PostgreSQL foram corrigidas; gosu foi removido do runtime PostgreSQL sempre sem root. O scanner mantém a excepção original limitada ao identificador público de commit previamente classificado, não para segredos.

Riscos residuais não bloqueantes do M0: protecção de main ainda não activada; avisos de depreciação da cadeia de desenvolvimento; sensibilidade do posto local a carga concorrente; necessidade de renovar scans no tempo. TLS, políticas institucionais de recuperação e a aceitação integral de produção são obrigações dos milestones canónicos posteriores, sem alegação de implantação.

Modelos/créditos: execução por um único agente Codex, sem afirmação de revisão por outro modelo. Os testes e os gates correram em processos locais e runners remotos distintos. Recomendações TERRA/SOL/ASTRA constam do plano; consumo exacto de créditos/tokens não foi disponibilizado. Revisão humana final permanece com o operador.

Recomendação: rever os artefactos e, apenas se aprovado, emitir nova ordem explícita para M1. Nenhuma funcionalidade de M1 foi implementada ou iniciada.
