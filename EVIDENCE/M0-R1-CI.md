# M0-R1 — CI remota comprovada

Repositório: https://github.com/dmskalunga-rgb/SGP_PLATAFORMA.git. Branch: main. Commit técnico validado: [d966c61](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/d966c61ec280cf0aeb1e6fe739771698e98ab623).

Workflow: **M0 Foundation Gate**. Run: [43006790217](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43006790217). Resultado: **success**. Todos os steps obrigatórios passaram. Conclusão do último job: 11/11/2026 às 11:50:46, África/Luanda.

| Job | ID | Resultado | Âmbito |
|---|---|---|---|
| Foundation tests | 130476154005 | success | install/lint/types/build/unit/PostgreSQL/migration/integration/browser/startup/health |
| Source security and SBOM | 130476154404 | success | policy, npm, segredos fonte/histórico, SAST, SCA, CycloneDX |
| Container security | 130476154189 | success | build 3 imagens, runtime least privilege, outage, scans e SBOMs |

Artefactos originais: [testes 13848288163](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43006790217/artifacts/13848288163), [segurança fonte 13848906430](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43006790217/artifacts/13848906430), [containers 13849271217](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions/runs/43006790217/artifacts/13849271217). Relatórios/SBOMs copiados e projecções revistas estão em M0-R1/, com ci-artifacts.json e SHA256SUMS.txt. A metadata completa de jobs/steps está nos logs do run e foi preservada, sem alteração, em artifacts/closure-preserved/ci-run.json. As projecções de browser/SCA indicam o hash e a localização do original.

Histórico de remediação: run 43004915621 falhou na sintaxe de uma regra SAST e em vulnerabilidades da base Nginx; run 43005776529 falhou no falso positivo do SHA público e nas vulnerabilidades adicionais da imagem PostgreSQL. Não foram simulados ou convertidos em aprovação: as causas foram corrigidas e o run acima executou tudo novamente com sucesso.

O commit inicial e os pushes foram efectuados com a autenticação existente, sem force push. Actions e scanners estão fixados, permissions=contents:read, sem deployment automático. A publicação posterior destes relatórios repete a mesma CI; o commit técnico acima permanece a referência imutável das evidências copiadas.

Protecção de branch: consulta real devolveu 404 Branch not protected; recomendações documentadas, activação não alegada.

## Publicação do fecho

O diff de fecho afecta apenas documentação e evidência; a configuração Gitleaks permanece exactamente igual à do commit técnico validado, com a única excepção original de identificador público. Não há alteração de código, dependências ou imagens. O workflow da publicação final deve passar os mesmos três jobs; o SHA e o run dessa publicação serão entregues no resultado final e podem ser conferidos nos [runs de main](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/actions?query=branch%3Amain). O identificador desta página descreve o run técnico imutável que produziu os artefactos preservados; não se inventa um SHA auto-referente para o próprio commit de documentação.
