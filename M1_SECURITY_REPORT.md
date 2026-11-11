# M1 — segurança no checkpoint M1A

Avaliação limitada à arquitectura. Contratos, ADRs e revisão independente constituem a evidência; não se afirma enforcement executado. Gate em EVIDENCE/M1/M1A/M1A-GATE.md.

## Threat model e controlos planeados

| Ameaça / actor | Boundary e controlo especificado | Prova futura obrigatória |
|---|---|---|
| Cliente altera role/scope/clearance ou chama API directa | DB autoritativo, contexto imutável, ADC default deny | API negativa e equivalência SQL |
| SQL no pool normal altera custom GUC | Binding privado backend+xid8, sem DML directo, helpers com grants mínimos | GUC poisoning/rebind/cross-session deny |
| Pool recicla conexão | Client pinned, SET LOCAL, rollback/finish, private binding transaccional e prazo | max=1 sob commit/rollback/timeout/cancel |
| Role A dá permission e role B dá outro scope | effective_grants mantêm vínculo permission/scope/location | Caso cartesiano deve negar |
| Sessão roubada/replay/CSRF | TLS, token opaco hash DB, cookie protegido, CSRF/Origin, rotation/revocation | Browser real e teste concorrente |
| Corrida de revogação/edição de role | Locks ADC ordenados, mutação exclusiva desde início e versões | Interleavings, timeouts, ausência de lock upgrade |
| Admin tenta elevar a si ou outro fora da delegação | Scope/ceiling/grantable, SoD, maker-checker, último admin | SOD-001–005 e acesso SQL protegido |
| Audit indisponível ou adulterada pelo runtime | Append restrito, mutações atómicas, rollback fail-closed | Falha injectada TEST, sem efeito/sessão persistida |

App runtime, auth runtime, migration e owners NOLOGIN são papéis distintos. RLS não constitui defesa contra superuser/DBA, credential de migration ou comprometimento total do processo auth confiável. Secrets, observabilidade, cópia externa de audit, recuperação e aprovação institucional são obrigações posteriores explícitas, sem alegar invulnerabilidade. Implementar funções SECURITY DEFINER/RLS só após autorização e testes adversariais.

Riscos arquitecturais e decisões: lock global serializa alterações IAM; pool de auth é fronteira privilegiada; parâmetros de hashing/timeouts precisam medição; nomenclatura classificativa exige PNA; bootstrap precisa identidades reais distintas; metadados de segurança exigem protecção sem recursão. Estado de findings independentes e resolução: ASTRA-REVIEW.md. Não há novas dependências, imagens ou configuração de scanner nesta subfase.
