# ADR-009 — Session Architecture

Estado: APPROVED/FROZEN M1A. Data: 2026-11-11.

Contexto: sessão institucional requer expiração/revogação verificável e credenciais isoladas. Username não é necessariamente email; login fake/JWT sem estado não atendem revogação.

Decisão: SES/1: identidade INTERNAL inicialmente, adaptadores futuros sem implementação. Argon2id com salt único, parâmetros versionados e calibração; auth_runtime em pool separado é boundary confiável de verificação/emissão. app_runtime não lê hashes nem emite sessão. Token opaco de 256 bits, apenas SHA-256 no DB; cookie __Host Secure/HttpOnly/SameSite Strict, TLS validada, Origin exacto e CSRF incluindo nonce de login. Sessão absoluta 8h, idle 15min; rotação explícita atómica sem grace e sem prolongar deadline absoluto. Revogação/status/credential changes seguem locks ADC/1. Banco/auditoria indisponível: sem sessão nova, sem sucesso protegido.

Alternativas rejeitadas: JWT stateless como autoridade institucional; token em localStorage; senha reversível; SHA simples de password; rotação em cada request; login CSRF sem protecção; contas default de bootstrap.

Consequências: consulta DB por pedido, TLS E2E e rate limiting/hashing bounded necessários. Compromisso da credencial auth/processo é violação do serviço confiável; RLS do pool normal não resolve esse actor. Bootstrap vazio auditado exige operadores reais distintos para administração privilegiada. Recuperação e retenção institucional devem ser aprovadas antes de produção.

Validação futura: credenciais, lockout/rate limit, rotação concorrente, idle/absolute expiry, revogação, CSRF/origin, logs e eventos auditáveis em PostgreSQL real. Não se alegam testes IAM executados em M1A.
