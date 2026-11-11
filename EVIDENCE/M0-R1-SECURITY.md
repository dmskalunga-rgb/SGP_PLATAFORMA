# M0-R1 — evidência de segurança

Run aceite: 43006790217, todos os controlos obrigatórios success. JSONs originais preservados em M0-R1/.

- Gitleaks 8.30.1: fonte e histórico completo com zero segredos.
- npm audit: zero info/low/moderate/high/critical. Sete MODERATE anteriores FIXED; decisões em M0-R1-DEPENDENCIES.md.
- Semgrep 1.185.0: 13 ficheiros analisados, zero findings e zero erros. A regra raw-HTML foi corrigida após erro de sintaxe no primeiro run; o controlo não foi retirado.
- Trivy 0.76.2 SCA: zero HIGH/CRITICAL no âmbito analisado.
- Trivy imagens: zero HIGH/CRITICAL para API, web e PostgreSQL após patches; sem ignore de advisories.
- Quatro SBOMs CycloneDX gerados e copiados com hashes.
- Scan de padrões proibidos: zero mocks operacionais. Ocorrências do master/scanner são referências não operacionais.

## Falso positivo de segredo, com evidência

O segundo run classificou o identificador do commit inicial como sourcegraph-access-token. A localização/colunas correspondem ao objecto Git público verificado, não a uma credencial. A configuração permite somente o identificador público do commit inicial previamente classificado. Não permite classes de hashes, caminhos inteiros de evidência, commits inteiros ou a desactivação da regra. Os scans continuam obrigatórios sobre fonte e histórico; rotação não se aplica a identificadores Git públicos. A metadata bruta redundante dos jobs foi preservada nos artefactos gerados; os relatórios versionados usam ligações Git públicas para identificar commits. Não foram adicionadas novas excepções.

## Remediação real de imagens

Nginx: brotli, curl/libcurl, libexpat, libxslt, musl/musl-utils e zlib foram actualizados para versões corrigidas fixadas. PostgreSQL: krb5-libs e libxslt actualizados e gosu removido, pois o runtime começa sempre como postgres, dispensando o helper de elevação com Go stdlib vulnerável. API, web e banco foram novamente construídos/testados/analisados; os relatórios aceites não contêm HIGH/CRITICAL.

Os scans locais interrompidos por download/contensão não substituem os scans remotos efectivamente concluídos. Não foi aceite risco crítico/alto para obter aprovação. Não se afirma segurança integral de módulos ou ambientes futuros.

## Preservation of generated identity metadata

The original CI job metadata, Playwright report and Trivy filesystem report include repeated public Git SHAs. Full, unchanged originals remain in the workflow artifacts and artifacts/closure-preserved locally. The repository contains reviewed browser/SCA summaries with the original SHA-256, run and artifact identifiers; vulnerability results and SBOMs remain available as versioned outputs. This avoids adding any secret-scan exception beyond the previously classified initial commit ID. The candidate source and full committed history are rescanned unchanged by this evidence projection.
