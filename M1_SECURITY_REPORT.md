# M1 — segurança M1B

Contratos M1A exactos e clarificação de scope preservados. [Hashing](EVIDENCE/M1/M1B/PASSWORD-HASHING.md), [calibração](EVIDENCE/M1/M1B/ARGON2-CALIBRATION.md), [bootstrap](EVIDENCE/M1/M1B/BOOTSTRAP.md), [audit](EVIDENCE/M1/M1B/AUDIT-EVIDENCE.md), [runbook](docs/operations/M1B-IDENTITY-RUNBOOK.md).

Argon2id/salt único/PHC e versionamento; sem credencial reversível. Token opaco256bit, só hash DB/cookie HttpOnly/Secure/Strict, sem localStorage/JWT. TLS e Origin exacto, CSRF e nonce5min de uso único. Sem bypass de Secure/CSRF para produção ou browser TEST. Rate budget DB, hashing bounded, lock AUTO15min não prolongável e lock MANUAL controlado.

App/auth separados e sem superuser/createdb/createrole/bypass, ownership ou DML IAM. FORCE RLS interno, SECURITY DEFINER mínimo/NOLOGIN/search_path seguro/nomes qualificados, EXECUTE PUBLIC revogado, sem SQL dinâmico nos comandos expostos. Hash lookup só auth pool, fronteira confiável declarada M1A. Binding backend+xid8, objecto request imutável, locks/deadlines; GUC isolado não autentica. Sem grant-all ou administração de entitlements.

Audit+mutação atómicos, failure rollback/503. Logs sanitizados testados contra secrets efémeros; outputs não exportam configuração secreta de fixtures. Bootstrap privado de deployment, duas identidades distintas, vazio/one-time; replay/runtime recusados. Migrations/checksums e hashes congelados protegidos em CI.

Npm audit/secret scan locais PASS; SAST/SCA/imagens/SBOM obrigatórios na CI final. Não declarar zero vulnerabilidades remotas antes da execução. Riscos auth service/DBA/recuperação/retencão/hardware/rede não são neutralizados por RLS. Sem PRODUCTION_READY ou avanço M1C/D/M2.
