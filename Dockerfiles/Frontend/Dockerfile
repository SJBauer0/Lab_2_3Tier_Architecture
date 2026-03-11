
# What is Multi Staging in Docker
# Multi staging was created to compact complex frameworks like Nextjs
# Frameworks have to be compiled, transpiled, and bundled which
# take much storage and it will cost more in AWS to store.
# 
# The Build Stage: Bundle all the compilers and dev dependencies. 
# Get back optimized package like  Next.js .next/standalone folder or a NestJS dist folder.
# 
# (The Production Stage): You start a completely brand new, empty container. 
# Now only use the finalized package, and put it in the image.
# 

# Base Setup
FROM node:22-alpine AS base 
RUN corepack enable pnpm

# Builder Stage
FROM base AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
# Ensure Next.js is configured for 'standalone' output
RUN pnpm build

# 3. Runner Stage (The AWS-bound Image)
FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production

# Create the user to avoid running as 'root' in EC2
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Switch to the restricted user early
USER nextjs

# The 'Hand-off' with correct ownership
# Without --chown, the 'nextjs' user might not have permissions 
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

EXPOSE 3000
# AWS Target Group will use this port for Health Checks
ENV PORT 3000

CMD ["node", "server.js"]