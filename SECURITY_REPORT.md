# M0-R1 — relatório de segurança

Aceitação da baseline de segurança M0: PASS no âmbito testado. Não é uma declaração de segurança integral do sistema futuro ou de produção.

| Controlo | Ferramenta/âmbito | Resultado |
|---|---|---|
| Segredos no conteúdo | Gitleaks 8.30.1, fonte e governação | zero segredos |
| Segredos no histórico | Gitleaks, checkout completo | zero segredos |
| Dependências npm | npm audit, todos os níveis | zero vulnerabilidades |
| SAST | Semgrep 1.185.0, regras versionadas | 13 ficheiros, zero findings, zero erros |
| SCA complementar | Trivy 0.76.2, lockfiles | zero HIGH/CRITICAL |
| Imagens | Trivy API/web/PostgreSQL | zero HIGH/CRITICAL em cada imagem |
| Inventário de software | CycloneDX | dependências e três imagens gerados |
| Privilégio mínimo | Containers e conta técnica PostgreSQL | UID não-root; sem superuser/createdb/createrole/bypassrls |
| Falha segura e erros | Integração/browser/smoke | dependência indisponível gera 503 sem dados internos |

As sete ocorrências MODERATE anteriores da cadeia minimatch/typescript-eslint foram corrigidas, com versões e impacto documentados em EVIDENCE/M0-R1-DEPENDENCIES.md. Não existe decisão IGNORE ou aceitação de vulnerabilidade crítica/alta.

Os scans remotos bloquearam inicialmente bibliotecas da base Nginx e depois PostgreSQL/gosu. Foram aplicadas versões corrigidas fixadas nos Dockerfiles e retirado o helper de elevação que não é utilizado num runtime sempre postgres. Os relatórios posteriores comprovam a correcção. Os scanners e Actions estão fixados por versão/digest/SHA e falham o workflow se um gate falhar.

O Gitleaks classificou um SHA público Git como Sourcegraph token. A revisão comprovou que se tratava do identificador do commit, sem credencial. A única excepção é limitada ao valor exacto do objecto Git público previamente classificado, para preservar a evidência; nenhuma classe de tokens ou histórico é ignorada. Fonte e histórico continuam obrigatoriamente analisados. Detalhes em EVIDENCE/M0-R1-SECURITY.md.

As imagens não recebem .env, credenciais de runtime, testes ou artefactos do posto. Credenciais de TEST são geradas por execução, mascaradas na CI e eliminadas com os recursos descartáveis. Logs técnicos sanitizam erros e não substituem auditoria institucional futura. Nenhum endpoint operacional ou funcionalidade IAM/M1 existe.

Limitações residuais: main está sem protecção activa; scans expiram no tempo e devem ser repetidos; ferramentas têm avisos não associados a advisories abertos; a revisão humana independente é posterior à entrega técnica. Não se afirma que TLS ou backup/restore institucionais estejam implantados.
