# M0-R1 — riscos residuais conhecidos

Não há gate crítico M0 aberto após o run validado e a revisão das evidências. M1 continua bloqueado por falta de nova autorização, mesmo com M0 aprovado.

1. main ainda não está protegida. Consulta à API GitHub devolveu Branch not protected (404). A recomendação de checks obrigatórios, revisão de PR e bloqueio de force push está em docs/operations/BRANCH-PROTECTION.md; activação não é alegada.
2. ESLint 9.39.1 emite aviso de versão sem suporte; Fastify 5 avisa de futura descontinuação de disableRequestLogging. São avisos da cadeia actual, com npm audit zero; planear actualização controlada sem alterar o gate retrospectivamente.
3. O posto Windows apresentou contenção ao executar simultaneamente scanners, builds e browser; uma repetição excedeu o timeout de disponibilidade. A suite final sem scans concorrentes e a CI passaram. Dimensionamento/carga institucional não foram aprovados pelo M0.
4. Scans representam a base de advisories no momento da execução. Repetir antes de novas promoções. Os pacotes Alpine fixados podem deixar de existir no mirror público; manter artefactos/digests e avaliar mirror institucional para reprodutibilidade.
5. Os artefactos Actions têm retenção de 30 dias. Uma cópia dos JSONs e SBOMs do run técnico foi preservada no repositório e os ficheiros originais também estão em artifacts/ci-code localmente.
6. Não houve revisão por um segundo modelo ou aprovação humana independente nesta sessão. A entrega inclui revisão técnica e validação automatizada em processos/runners separados; a decisão humana e autorização de M1 cabem ao operador.
7. TLS, RPO/RTO, backup/restore, ambientes institucionais e o sistema operacional completo permanecem obrigações dos milestones canónicos apropriados. Não há implantação de produção nem declaração PRODUCTION_READY.
