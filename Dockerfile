ARG CR=univer-acr-registry.cn-shenzhen.cr.aliyuncs.com
FROM ${CR}/devops/node:20-alpine AS base

# Builder stage
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
FROM base AS builder
WORKDIR /app

ARG NPM_REGISTRY=""
RUN [[ "${NPM_REGISTRY}" != "" ]] && npm config set registry ${NPM_REGISTRY} || echo "Skip setting NPM_REGISTRY"

COPY . .
RUN corepack enable pnpm && pnpm i

# Algolia
ARG NEXT_PUBLIC_ALGOLIA_APP_ID
ARG NEXT_PUBLIC_ALGOLIA_SEARCH_API_KEY
ARG NEXT_PUBLIC_ALGOLIA_INDEX_NAME
RUN echo "NEXT_PUBLIC_ALGOLIA_APP_ID=${NEXT_PUBLIC_ALGOLIA_APP_ID}" >> .env
RUN echo "NEXT_PUBLIC_ALGOLIA_SEARCH_API_KEY=${NEXT_PUBLIC_ALGOLIA_SEARCH_API_KEY}" >> .env
RUN echo "NEXT_PUBLIC_ALGOLIA_INDEX_NAME=${NEXT_PUBLIC_ALGOLIA_INDEX_NAME}" >> .env

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
# Uncomment the following line in case you want to disable telemetry during the build.
ENV NEXT_TELEMETRY_DISABLED=1
RUN pnpm build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
# Uncomment the following line in case you want to disable telemetry during runtime.
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Set the correct permission for prerender cache
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static .next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000

# server.js is created by next build from the standalone output
# https://nextjs.org/docs/pages/api-reference/next-config-js/output
ENV HOSTNAME="0.0.0.0"
CMD ["node", "server.js"]
