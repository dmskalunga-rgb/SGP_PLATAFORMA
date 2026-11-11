# Comandos e limites da verificação M1A

Executados no PowerShell em D:\SGP_PLATAFORMA, 2026-11-11. A revisão ASTRA ocorreu em contexto separado e foi repetida após correcções. As verificações abaixo são documentais; não são testes de IAM implementado.

1. `Get-FileHash SGP-DISPO-MASTER-v1.0-FROZEN.md`: hash histórico confirmado.
2. `git status --short`, `git diff --exit-code HEAD`, `git diff --check`, `git ls-files --eol`: apenas adições documentais M1A. O checkout Windows contém CRLF em alguns ficheiros cujo blob Git tem LF; igualdade refere-se ao conteúdo controlado normalizado por Git, não a identidade binária indiscriminada com blobs. Nenhum ficheiro M0 foi editado nesta execução.
3. `npm run test:policy`: exit 0, operationalFindings=0. Menções no scanner/master são referências, não mocks operacionais.
4. Secret scan, sem alterar allowlists:

```powershell
docker run --rm --mount 'type=bind,source=D:\SGP_PLATAFORMA,target=/src' ghcr.io/gitleaks/gitleaks:v8.30.1 dir /src --config /src/.gitleaks.toml --redact --report-format json --report-path /src/artifacts/gitleaks-m1a.json
```

Exit 0; no leaks found; JSON []. Cópia do resultado: GITLEAKS-SOURCE.json. As exclusões existentes abrangem outputs/dependências/segredos TEST; docs e EVIDENCE permanecem incluídos. Não foi feito scan novo de histórico, imagens ou dependências: esses controlos pertencem à CI da base M0, preservada, e aos gates futuros de implementação.

Uma repetição intermédia após gerar o verificador sinalizou duas ocorrências pela regra sourcegraph-access-token: o SHA público do commit base, em COMMANDS.md e CHECKS.json. Classificação: falso positivo verificado contra git HEAD, CI e link público em BASELINE.md; não eram credenciais. Relatório redactado preservado em GITLEAKS-INTERMEDIATE-REDACTED.json. O verificador passou a comparar o SHA completo com o registo da CI e a exportar o link como Markdown. Não houve nova allowlist nem exclusão. O scan final deve passar antes do gate.

5. Freeze: cada um dos 11 hashes DRAFT recebidos do revisor foi comparado antes da escrita. Só foram trocados os estados DRAFT/PROPOSED para FROZEN/APPROVED, conservando todos os restantes bytes. Manifesto final preserva os dois hashes; o verificador abaixo reconstrói o draft e confirma igualdade.
6. Verificador executado abaixo, extraído deste bloco para `python -`; produz CHECKS.json e exit diferente de zero se qualquer condição falhar. O resultado é actualizado depois de acrescentar o gate para incluir todos os ficheiros da entrega.

```python
from pathlib import Path
import datetime, hashlib, json, subprocess
root = Path.cwd()
ev = root / 'EVIDENCE/M1/M1A'
def digest(data):
    return hashlib.sha256(data).hexdigest().upper()
def git(*args):
    return subprocess.run(['git', *args], capture_output=True, text=True, check=False)
checks = {}
master = digest((root/'SGP-DISPO-MASTER-v1.0-FROZEN.md').read_bytes())
checks['master_integrity'] = master == '7CDE06093C1A3F0D7EF7C463BC7EE08CB4FCAC48F4B149D377166C0FF171A667'
head = git('rev-parse','HEAD').stdout.strip()
ci = json.loads((root/'artifacts/M0-R1-FINAL-CI.json').read_text(encoding='utf-8-sig'))
checks['base_commit_unchanged'] = head == ci['headSha'] and head.startswith('8d8583c')
checks['tracked_M0_content_unchanged_git_normalized'] = git('diff','--exit-code','HEAD').returncode == 0
checks['git_diff_check'] = git('diff','--check').returncode == 0
untracked = git('ls-files','--others','--exclude-standard').stdout.splitlines()
root_reports = {'M1_MILESTONE_REPORT.md','M1_TEST_REPORT.md','M1_SECURITY_REPORT.md','M1_TRACEABILITY_UPDATE.md','M1_KNOWN_ISSUES.md'}
review = json.loads((ev/'REVIEWED-DRAFT-HASHES.json').read_text(encoding='utf-8-sig'))
manifest = json.loads((ev/'FREEZE-MANIFEST.json').read_text(encoding='utf-8-sig'))
checks['only_authorized_M1A_documents_added'] = all(p in root_reports or p in review['files'] or p == 'docs/requirements/M1A-PLAN.md' or (p.startswith('EVIDENCE/M1/M1A/') and Path(p).suffix in {'.md','.json'}) for p in untracked)
checks['seven_contracts_four_ADRs'] = len(manifest['files']) == 11 and sum(f['path'].startswith('docs/security/') for f in manifest['files']) == 7 and sum(f['path'].startswith('docs/adr/ADR-') for f in manifest['files']) == 4
freeze = []
for entry in manifest['files']:
    name = entry['path']
    raw = (root/name).read_bytes()
    frozen,draft = (b'Estado: FROZEN/APPROVED M1A',b'Estado: DRAFT M1A') if name.startswith('docs/security/') else (b'Estado: APPROVED/FROZEN M1A',b'Estado: PROPOSED M1A')
    freeze.append(raw.count(frozen) == 1 and digest(raw) == entry['sha256'] and digest(raw.replace(frozen,draft,1)) == review['files'][name] == entry['reviewed_draft_sha256'])
checks['freeze_hashes_and_reviewed_semantic_identity'] = all(freeze)
required = list(root_reports) + ['docs/requirements/M1A-PLAN.md'] + list(review['files']) + ['EVIDENCE/M1/M1A/'+p for p in ['BASELINE.md','ASTRA-REVIEW.md','REVIEWED-DRAFT-HASHES.json','FREEZE-MANIFEST.json','COMMANDS.md','GITLEAKS-SOURCE.json']]
checks['required_checkpoint_artifacts_present'] = all((root/p).is_file() and (root/p).stat().st_size > 0 for p in required)
ci = json.loads((root/'artifacts/M0-R1-FINAL-CI.json').read_text(encoding='utf-8-sig'))
checks['M0_baseline_CI_record_success'] = ci['headSha'] == head and ci['conclusion'] == 'success' and len(ci['jobs']) == 3 and all(j['conclusion'] == 'success' for j in ci['jobs'])
checks['secret_scan_zero_findings'] = json.loads((ev/'GITLEAKS-SOURCE.json').read_text(encoding='utf-8-sig')) == []
policy = subprocess.run(['node','scripts/check-policy.mjs'], capture_output=True, text=True)
policy_summary = json.loads(policy.stdout.strip().splitlines()[-1])
checks['operational_mock_policy'] = policy.returncode == 0 and policy_summary['operationalFindings'] == 0
checks['no_merge_markers_in_added_documents'] = all(not any(line.startswith(('<<<<<<< ','=======','>>>>>>> ')) for line in (root/p).read_text(encoding='utf-8-sig').splitlines()) for p in untracked if Path(p).suffix == '.md')
out = {'scope':'M1A documentary verification only','checked_at_UTC':datetime.datetime.now(datetime.timezone.utc).isoformat(),'master_sha256':master,'base_commit_link':'['+head[:7]+'](https://github.com/dmskalunga-rgb/SGP_PLATAFORMA/commit/'+head+')','branch':git('branch','--show-current').stdout.strip(),'checks':checks,'policy_summary':policy_summary,'baseline_CI':{'run':ci['databaseId'],'conclusion':ci['conclusion'],'jobs':[{'name':j['name'],'conclusion':j['conclusion']} for j in ci['jobs']]},'new_documents':untracked,'all_automated_document_checks_pass':all(checks.values()),'IAM_operational_tests':'NOT_RUN_NOT_IMPLEMENTED','new_M1_workflow':'NONE','independent_review':'ASTRA-REVIEW.md; technical architecture approval, four findings closed'}
(ev/'CHECKS.json').write_text(json.dumps(out,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps({'checks':checks,'policy_summary':policy_summary,'all_pass':all(checks.values())}))
raise SystemExit(0 if all(checks.values()) else 1)
```

Para repetir a verificação são necessários os metadados locais da CI M0, ignorados por Git, em artifacts/M0-R1-FINAL-CI.json; a fonte pública é o workflow 43014470020 ligado em BASELINE.md. CHECKS.json conserva o resumo dos três jobs. Nem esse resumo nem a CI da base são apresentados como testes IAM M1 novos.

Referência para o limite transaccional especificado, consultada durante o desenho: [PostgreSQL 17 client defaults](https://www.postgresql.org/docs/17/runtime-config-client.html). Os timeouts de 15s/5s/2s são decisões do projecto a medir, sem mudança de configuração durante M1A.
