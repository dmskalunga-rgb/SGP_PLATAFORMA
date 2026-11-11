# M0-R1 — containers aceites

Três imagens foram construídas e verificadas: sgp-api:m0, sgp-web:m0 e sgp-postgres:m0. Bases oficiais fixadas por digest; pacotes corrigidos de web/PostgreSQL fixados nos Dockerfiles. API runtime recebe apenas dependências de produção e remove npm/Yarn; web contém apenas assets compilados e Nginx; PostgreSQL inicia como postgres e dispensa gosu.

Teste final local e remoto: PostgreSQL UID 70, API UID 1000, web UID 101; filesystem readonly; todas as capabilities removidas; no-new-privileges; CPU/memória/PIDs limitados; permissões de leitura adequadas; healthchecks saudáveis; migrations/ready reais. A consulta web passa pelo proxy configurável. Parar o banco gera ready 503 enquanto live permanece 200. O helper cria /tmp/conf.d sem root para suportar envsubst no filesystem readonly.

Trivy final: zero HIGH/CRITICAL em cada imagem. SBOMs CycloneDX: API 99 componentes, web 71, PostgreSQL 46; SBOM de dependências de produção 59 componentes. Artefactos completos em M0-R1/{api,web,postgres}-vulnerabilities.json e respectivos .cdx.json. Os números são contagens dos artefactos técnicos, não indicadores operacionais.

O scan inicial bloqueou CVEs em brotli/curl/expat/xslt/musl/zlib; o scan seguinte detectou krb5/xslt e Go stdlib de gosu no banco. Cada causa foi corrigida; não há supressão desses findings. Raw reports aceites e hashes estão preservados. Compose incorpora as mesmas imagens/restrições, rede interna do banco e web limitada a loopback. Produção institucional ainda exige os seus gates próprios.
