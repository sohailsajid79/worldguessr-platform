# syntax=docker/dockerfile:1.7
ARG NODE_VERSION=22

FROM node:${NODE_VERSION}-slim AS base
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0 PNPM_HOME=/pnpm PATH=/pnpm:$PATH
RUN corepack enable && corepack prepare pnpm@9.15.9 --activate
WORKDIR /app

FROM base AS deps
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY mobile/package.json mobile/package.json
RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm config set store-dir /pnpm/store && \
    pnpm install --frozen-lockfile --prod --filter '!worldguessr-mobile'

FROM base AS runtime
ENV NODE_ENV=production
COPY --from=deps /app/node_modules ./node_modules
COPY . .
USER node

FROM runtime AS api
EXPOSE 3001
CMD ["node", "server.js"]

FROM runtime AS auth
EXPOSE 3004
CMD ["node", "authServer.js"]

FROM runtime AS ws
ENV UWS_HTTP_MAX_HEADERS_SIZE=16384
EXPOSE 3002
CMD ["node", "ws/ws.js"]

FROM runtime AS cron
EXPOSE 3003
CMD ["node", "cron.js"]
