FROM docker.io/node:21-alpine AS base

RUN apk add --no-cache git sed
WORKDIR /app

ENV COMMIT_SHA '5d9a1c9ac4c4a736f9a3db18c8ae4312af9729a2'
RUN git config --global advice.detachedHead false && \
    git clone https://github.com/viclafouch/meme-studio.git -b master /app && \
    cd /app && git checkout $COMMIT_SHA

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
ENV NEXT_TELEMETRY_DISABLED 1

FROM base AS builder

RUN apk add --no-cache libc6-compat
RUN npm ci

# Adjust source to work in a self-hosted variant
RUN npm install sharp
RUN sed -i "/const nextConfig =/a output: 'standalone'," /app/next.config.js \
    && sed -i "/const nextConfig =/a eslint: { ignoreDuringBuilds: true, }," /app/next.config.js \
    && sed -i "/remotePatterns/,/]/d" /app/next.config.js \
    && sed -i "s|https://www.meme-studio.io|http://localhost|" /app/src/shared/constants/env.ts

RUN npm run build --omit=dev

RUN ls -al /app/.next

# Production image, copy all the files and run next
FROM docker.io/node:21-alpine AS runner

ENV NODE_ENV production
# Disable telemetry during runtime.
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Set the correct permission for prerender cache
RUN mkdir .next
RUN chown nextjs:nodejs .next

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000
ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

ENTRYPOINT ["node", "server.js"]
