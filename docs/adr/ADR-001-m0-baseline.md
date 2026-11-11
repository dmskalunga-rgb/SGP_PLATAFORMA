# ADR-001 — M0 stack and verification

Status: accepted for M0 implementation, subject to the formal gate. Context: preserve the existing canonical React/Vite, Fastify/TypeScript and PostgreSQL workspace. Decision: retain this stack; separate the API factory from startup for real integration tests; apply versioned migrations through transactional PostgreSQL locks/checksums; use same-origin web proxy configuration; use non-root multi-stage images with production-only dependencies.

Security evidence is generated locally and in GitHub Actions. Mandatory checks fail closed and remote CI is required for M0-R1. npm overrides minimatch to a patched version in the development-only lint toolchain; tests and fresh audit must validate this compatibility choice. No IAM/RBAC/ABAC or functional RLS decisions are made in this ADR.

Consequences: no mock adapters are needed; the baseline remains small and testable. Production networking, TLS, secrets and recovery must undergo their canonical deployment gates.
