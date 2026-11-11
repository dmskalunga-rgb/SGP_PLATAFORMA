# Calibração Argon2id

Medição real por node scripts/calibrate-argon2.mjs: sete hash+verify com password efémera CSPRNG não exportada. Resultado completo: ARGON2-CALIBRATION.json, incluindo CPU/OS/Node, tempos individuais e parâmetros. A CI volta a medir no runner Linux; não confundir hardware de desenvolvimento com infraestrutura institucional.

Parâmetros: memória65536KiB, time_cost3, parallelism1, salt16bytes, hash32bytes, PHC version19. Primeira medição local teve mediana207ms; repetição sob carga teve mediana267ms e máximo299ms. Manter baseline congelada, concorrência2 por processo e quotas antes do hashing, sem fila ilimitada. Valores observados não são SLA de produção; reservar memória e recalibrar no hardware alvo antes de implantação. Alteração de arquitectura exige CR; elevar parâmetros continua sujeita a medição e versionamento.
