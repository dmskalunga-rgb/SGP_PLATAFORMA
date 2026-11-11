# M1 — relatório de testes M1C

Suite candidata: 4 testes unitários, 36 de integração PostgreSQL/API (19 M1C, 13 M1B, 4 M0), 2 browser M0 e 4 browser TLS de identidade/autorização. Sem mocks operacionais. Bases TEST efémeras e credenciais aleatórias são removidas pelos respectivos harnesses.

A suite M1C compara API/SQL, grants não cartesianos, scope/location, todos os limiares de rank, clearances ausentes/expiradas, todos os compartimentos, estados inactivos, versões/context/GUC, FORCE RLS e ACL por runtime; INSERT/UPDATE WITH CHECK e DELETE separado em tabela técnica TEST; comandos reais/negativos por executor; SoD futuro/indirecto; delegação, approvals, replay, maker expirado; audit rollback; pool/savepoints; revogação e remoções concorrentes. Três E2Es reais provam configuração/acesso, maker-checker e revogação.

Frontend: botão indisponível ocultado após retirada real de permission; API directa continua a negar. Regressão M1B preserva TLS/cookie/CSRF/password/lockout/sessões/pool/deadline real.

Resultados locais e hashes em EVIDENCE/M1/M1C/CHECKS.json. CI e revisão independente são condições separadas; ver CI.md nessa pasta e atestação final do commit. Não confundir execução local com gate remoto.
