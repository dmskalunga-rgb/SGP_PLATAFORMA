FROM node:24.22.2-alpine@sha256:a34ab6d7f6f4813f4d0c5469d74685604b962fbdbf5793a7bc7b4998ecb867c8 AS build
WORKDIR /app
COPY package*.json ./
COPY apps/api/package.json apps/api/package.json
COPY apps/web/package.json apps/web/package.json
RUN npm ci --no-audit --no-fund
COPY apps/web apps/web
RUN npm run build -w @sgp/web

FROM nginxinc/nginx-unprivileged:stable-alpine@sha256:f5116ed4606f3eb015dd4a8e28cb9b351476dc0ad4bc6e9f93b19cec130cdf03
# Security patch versions from the blocking Trivy report; runtime returns to UID 101.
USER 0
RUN apk add --no-cache --upgrade brotli-libs=1.2.1-r0 curl=8.23.0-r0 libcurl=8.23.0-r0 libexpat=2.10.0-r0 libxslt=1.1.43-r4 musl=1.2.6-r3 musl-utils=1.2.6-r3 zlib=1.4-r0
ENV NGINX_ENVSUBST_OUTPUT_DIR=/tmp/conf.d API_UPSTREAM=http://api:3000
COPY --chmod=755 infrastructure/nginx/19-create-config-dir.sh /docker-entrypoint.d/19-create-config-dir.sh
COPY infrastructure/nginx/nginx.conf /etc/nginx/nginx.conf
COPY infrastructure/nginx/default.conf.template /etc/nginx/templates/default.conf.template
COPY infrastructure/nginx/auth-tls.conf.template /etc/nginx/auth-tls.conf.template
COPY --from=build /app/apps/web/dist /usr/share/nginx/html
USER 101
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 CMD wget -q -O /dev/null http://127.0.0.1:8080/ || exit 1
