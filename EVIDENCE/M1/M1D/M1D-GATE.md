# M1D — final documentary gate dossier

Current state: **PENDING EXPLICIT HUMAN GATE DECISION**. This dossier consolidates evidence; it does not grant M1D_GATE PASS, merge, production deployment, M2 or CR-SGP-002 authority.

Technical candidate: `9e1fe6bd3f8219a1b267eadb8e80458f221b699e`. Documentary risk-registration baseline:49ec7d7. Functional sources and published migrations001–006 are unchanged by this consolidation. Masterv1.1 and11 M1A FROZEN artefacts remain preserved.

| Requirement | Verified evidence |
|---|---|
| Real API/frontend/PostgreSQL, migration006, authorization/RLS/FORCE, SoD, maker-checker, audit and rollback | Technical CI direct43805975302 and PR43805979032 SUCCESS;56 normal tests per run:4unit45integration2baseline5TLS, zero failures/skips, browser zero flaky |
| Build/lint/typecheck/frozen/policy | PASS in both technical runs |
| SAST, Gitleaks, npm audit, SCA, image gates, SBOM | PASS; four SBOM per technical run; Trivy HIGH/CRITICAL scope, npm audit all severities |
| Identity DENY, role-status audit, TLS initialization and TEST lifecycle findings | Technically remediated and independently verified; success/failure cleanup has acknowledged app.close, zero connections, DROP without FORCE and database absence |
| Independent technical review | READY_FOR_GATE_REVIEW; exact report/hash referenced in FINAL-EVIDENCE-MANIFEST.json |
| Residual503 governance | Conditionally accepted by the signed risk record for M1D closure; root cause investigation remains OPEN |
| Final documentary CI and independent attestation | Required on the final published documentary candidate; results bind separately without a self-referential source hash |

Risk record M1D-RISK-503-001-ACCEPTANCE.md identifies Kalunga Soares as technical responsible and acceptance authority, declared Proprietario do Sistema. Investigation:15 calendar days after valid formalization. Recorded date2026-11-16 gives proposed deadline2026-12-01, subject to the original record's validity/counting condition. Monitor503/SQLSTATE/latency/timeouts/locks/pools; preserve sanitized evidence and reopen on the specified recurrence, audit or security conditions. This acceptance does not claim the503 root cause is fixed.

The base documentary CI43843545940 passed Foundation and Containers but failed Source security on two references to the verified public technical Git ID in the acceptance record. DOCUMENTARY-SCAN-TRIAGE.json retains the failure and proof. The scanner correction is restricted to that exact value/rule; coverage/default rules remain intact.

FINAL-EVIDENCE-MANIFEST.json inventories versioned evidence using exact Git blob bytes, independently of checkout CRLF/LF conversion. Persisted external artefacts use raw-byte hashes; historical manifests retain their original semantics. DOCUMENTARY-INDEPENDENT-ATTESTATION.md binds the documentary payload. Formal PASS/FAIL belongs to the human gate authority after evaluating final CI, independent attestation and accepted conditions. **No automatic PASS. M2 BLOCKED.**

---

## Historical candidate statements (superseded as current status, preserved for continuity)

# M1D — M1D-GATE

Candidate only. M1D_GATE is not PASS before complete local validation, new exact-SHA remote CI/security evidence and independent read-only review. Required gates: M0/M1A/M1B/M1C, all IAM administration domains, self/last-admin/second-operator protections, API/DB negatives, HIGH-001/MEDIUM-001 regressions, browser/API E2E, audit reconstruction, scanners/SBOM, zero operational mocks. M2 remains BLOCKED.

Proof sources: tests/integration/authorization.test.mjs (two M1D cases and preserved M1C), tests/auth-browser/m1d.spec.mjs; local final log artifacts/m1d-final-local-regression.log. Candidate validation, not a final remote PASS.

VERIFY-001 locally remediated and validated: focal2/2 and affected authorization25/25 PASS. Readiness READY_FOR_TECHNICAL_COMMIT; this is not M1D_GATE PASS. Remote CI and independent review remain pending. Intermediate503 and final strict success retained in evidence. M2 BLOCKED.
