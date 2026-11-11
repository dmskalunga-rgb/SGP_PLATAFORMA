FROM postgres:17-alpine@sha256:3540c0362c809df084ffac0ae69fe794515f9de92692f02178bcdce0ef0302ac
USER 0
RUN apk add --no-cache --upgrade krb5-libs=1.22.3-r0 libxslt=1.1.43-r4 && rm -f /usr/local/bin/gosu
# The privilege-changing helper is unnecessary: this image always starts as postgres.
USER postgres
HEALTHCHECK --interval=10s --timeout=3s --start-period=20s --retries=6 CMD pg_isready -h 127.0.0.1 -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" || exit 1
