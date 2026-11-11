# M1B — gate de identidade e sessão

Estado: READY_FOR_GATE. Gate final exige commit/push e CI remota do SHA exacto. Resultados locais não declaram PASS remoto. O registo final descrito em CI.md contém a decisão M1B_GATE e o workflow verificável, sem alterar a árvore validada.

| Critério obrigatório | Evidência local | Exigência de fecho |
|---|---|---|
| PostgreSQL schema | migration002 real | Foundation tests remoto |
| Migrations | apply/repeat/checksum/DDL rollback PASS | Foundation tests remoto |
| Users lifecycle | ACTIVE/INACTIVE/LOCKED/DISABLED + comandos auditáveis PASS | Repetir CI |
| Credential storage | separada/hash-only/no runtime disclosure PASS | Repetir CI |
| Argon2id | salt/hash/PHC/calibração PASS | Calibração runner+unit |
| Password policy | NFC15–128/config/weak list/limits PASS | Unit+integration |
| Login / Failure handling | valid/invalid/unknown/status/input/Origin/CSRF PASS | DB/API/browser |
| Lockout/rate | 5falhas/15min + unlock + janela60s + nonce replay PASS | Repetir CI |
| Session creation/persistence | PostgreSQL real/token hash/CSPRNG PASS | DB/API/browser |
| Session expiration | absolute8h/idle15min PASS | Repetir CI |
| Session revocation | one/all/logout/password/admin/rotation/replay PASS | Repetir CI |
| Logout | server revoke e duplo logout PASS | Browser+API |
| Context isolation | A/B, poolmax1, imutável, GUC/rollback/rebind PASS | DB/API |
| Audit | eventos/atomicidade/falha rollback/logs sem secrets PASS | DB/API/browser |
| Bootstrap security | real CLI, duas identities/vazio/one-time/private PASS | E2E+DB |
| Frontend login / Browser E2E | 3 cenários TLS reais PASS | Repetir CI |
| API / Database / Security tests | 17 integração PASS,4 unit PASS | Foundation tests remoto |
| M0 regression | 2 browser e4 integrações M0 preservados PASS | Três jobs M0 |
| M1A integrity | master+onze hashes exactos e guard positivo/negativo PASS | Frozen guard CI |
| CI | PENDING_REMOTE | Foundation tests + Source security and SBOM + Container security success |
| SAST | PENDING_FINAL | Semgrep zero findings/errors |
| SCA | npm audit zero; Trivy PENDING_REMOTE | zero HIGH/CRITICAL não decidida |
| Secret scan | worktree zero; candidato/histórico finais obrigatórios | Gitleaks source+history zero |
| Container scan / SBOM | build API com Argon2 real PASS; scans pendentes | smoke+Trivy API/web/PostgreSQL e CycloneDX |
| No operational mocks | política zero em apps/packages | CI test:policy |
| Artefactos/rastreabilidade | pasta M1B + cinco relatórios/runbook/OpenAPI | Presença/coerência antes do commit |

RLS implementado apenas interno, expressamente autorizado pelo operador para cumprir M1A. Não existe motor RBAC/ABAC/RLS de negócio, classificação/compartimentação de recursos ou administração completa M1D. Sem M2. Contratos congelados não mudaram. Reset remoto não é publicado; sem botão/endpoint falso.

Fecho permitido somente depois de todos os critérios remotos: M1B_GATE = PASS e M1C = BLOCKED_PENDING_EXPLICIT_AUTHORIZATION. Se crítico falhar, M1B_GATE = FAIL e M1C = BLOCKED. STOP sem iniciar M1C/M1D/M2. Riscos: M1_KNOWN_ISSUES.md e nota final pós-CI; nenhuma alegação PRODUCTION_READY.
