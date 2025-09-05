FROM oven/bun:alpine AS base

FROM base AS deps
WORKDIR /app

# Install dependencies
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# Copy source code
COPY . .

# Run the app
USER hono
EXPOSE 5050/tcp
CMD ["bun", "src/index.ts"]