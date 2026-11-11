# M0-R1 — revisão da decisão de gate

Âmbito revisto: somente foundation/governance, sem entidades ou APIs de M1. O agente implementador reviu os diffs e a rastreabilidade; processos locais e runners remotos independentes executaram os testes/scanners. Não se apresenta esta revisão como uma segunda revisão humana ou de outro modelo.

Verificações: URL/configuração obrigatória, bind loopback por defeito, SQL sem entrada operacional concatenada, erro/credencial sanitizados, migrations com lock/checksum/transacção e rollback provado, readiness dependente de PostgreSQL/schema reais, frontend sem dados inventados e com upstream externo, runtime sem root/sem tooling de dev, falha real de banco, scanners activos sem risco crítico/alto aceite, excepções estritas de identificadores Git públicos, credenciais TEST efémeras, fonte/histórico verificados e ausência de implantação automática.

DoR e DoD foram confrontados com cada gap na matriz de rastreabilidade. As falhas anteriores têm causa e nova evidência; não se usa auto-aprovação baseada apenas na existência de ficheiros. Leitura dos JSONs finais confirmou zero npm findings, zero SAST findings/erros, zero segredos e zero HIGH/CRITICAL nas três imagens. Quatro CycloneDX foram lidos e as cópias possuem SHA-256.

Conclusão técnica: os critérios obrigatórios do M0 estão evidenciados. Riscos residuais e limites constam de KNOWN_ISSUES.md. A decisão humana e uma eventual ordem M1 permanecem fora desta execução.
