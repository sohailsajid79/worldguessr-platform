# syntax=docker/dockerfile:1.7
ARG NODE_VERSION=22

FROM node:${NODE_VERSION}-slim AS build
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0 PNPM_HOME=/pnpm PATH=/pnpm:$PATH NEXT_TELEMETRY_DISABLED=1
RUN corepack enable && corepack prepare pnpm@9.15.9 --activate
WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY mobile/package.json mobile/package.json
RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm config set store-dir /pnpm/store && \
    pnpm install --frozen-lockfile --filter '!worldguessr-mobile'

COPY . .

ARG NEXT_PUBLIC_API_URL=localhost:3001
ARG NEXT_PUBLIC_AUTH_URL=localhost:3004
ARG NEXT_PUBLIC_WS_HOST=localhost:3002
ARG NEXT_PUBLIC_GOOGLE_CLIENT_ID=
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL \
    NEXT_PUBLIC_AUTH_URL=$NEXT_PUBLIC_AUTH_URL \
    NEXT_PUBLIC_WS_HOST=$NEXT_PUBLIC_WS_HOST \
    NEXT_PUBLIC_GOOGLE_CLIENT_ID=$NEXT_PUBLIC_GOOGLE_CLIENT_ID

RUN pnpm build

FROM nginxinc/nginx-unprivileged:1.27-alpine AS web
COPY <<'NGINXCONF' /etc/nginx/conf.d/default.conf
server {
    listen 8080;
    root /usr/share/nginx/html;
    index index.html;

    gzip on;
    gzip_types text/css application/javascript application/json image/svg+xml;

    location /_next/static/ {
        add_header Cache-Control "public, max-age=31536000, immutable";
    }

    location / {
        try_files $uri $uri.html $uri/ /index.html;
    }
}
NGINXCONF
COPY --from=build /app/out /usr/share/nginx/html
EXPOSE 8080