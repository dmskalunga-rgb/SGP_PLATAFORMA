# Backup and recovery governance

M0 contains only technical migration metadata. Disposable TEST data is not an institutional backup. No backup/restore acceptance for production is claimed.

Before production the institution must approve RPO, RTO, retention, encrypted full backups, WAL/PITR strategy where applicable, off-host storage, credentials, responsible team and restore validation. A backup without a tested restore is insufficient. Procedures must restore into an isolated environment, validate migrations and application health, record results and protect logs and evidence. The M0 gate does not replace the canonical backup/restore production gate.
