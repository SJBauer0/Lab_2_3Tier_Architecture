# What is Multi Staging in Docker
# Multi staging was created to compact complex frameworks like Nextjs
# Frameworks have to be compiled, transpiled, and bundled which
# take much storage and it will cost more in AWS to store.
# 
# The Build Stage: Bundle all the compilers and dev dependencies. 
# Get back optimized package like  Next.js .next/standalone folder or a NestJS dist folder.

# (The Production Stage): You start a completely brand new, empty container. 
# Now only use the finalized package, and put it in the image.
FROM node:22-alpine AS base
# Enable pnpm without having to manually download it
RUN corepack enable pnpm

# Create a new temporary environment
FROM base AS builder
# Move to the /app directory
WORKDIR /app
# Copy the package.json and the lock.yaml file to the root
COPY package.json pnpm-lock.yaml ./
# Install the heavy packages
RUN pnpm install --frozen-lockfile
# Copy the rest of the code
COPY . .
# Generate the Prisma client and run the build to create the dist folder with the compiled code.
RUN pnpm db:generate
# Run the build
RUN pnpm build

# Fresh start with the essential to without the heavy dev tools from builder tools
FROM base AS prod-deps
# Move to the /app directory
WORKDIR /app
# Copy the package.json and the lock.yaml file to the root
COPY package.json pnpm-lock.yaml ./
# Install only prod deps
RUN pnpm install --prod --frozen-lockfile
# Copy the prisma directory so the generator has the schema
COPY prisma ./prisma
# Use the locally installed prisma to generate the client
RUN pnpm exec prisma generate

FROM base AS runner
WORKDIR /app
# Run node.js with the fastest, most secure mode
ENV NODE_ENV=production

# Pluck the compiled code from builder
COPY --from=builder --chown=nestjs:nodejs /app/dist ./dist

# Pluck the cleanly generated production node_modules from prod-deps
COPY --from=prod-deps --chown=nestjs:nodejs /app/node_modules ./node_modules

# COPY THE FULL PRISMA CLI PACKAGES 
COPY --from=builder --chown=nestjs:nodejs /app/node_modules/prisma /app/node_modules/prisma
COPY --from=builder --chown=nestjs:nodejs /app/node_modules/@prisma /app/node_modules/@prisma
COPY --from=builder --chown=nestjs:nodejs /app/node_modules/.bin /app/node_modules/.bin

# Copy the prisma directory so migration deploy works at runtime
COPY --from=prod-deps --chown=nestjs:nodejs /app/prisma ./prisma

# Open the correct API port
EXPOSE 3001

# Start the NestJS application
CMD ["node", "dist/main.js"]