FROM oven/bun:1.4.2-alpine

WORKDIR /app

# Install production dependencies only.
COPY --chown=bun:bun package.json bun.lock ./
RUN bun install --frozen-lockfile --production

# Copy application source with the runtime user's ownership.
COPY --chown=bun:bun src ./src

# Runtime configuration
ENV APP_PORT=3000
EXPOSE 3000

USER bun
CMD ["bun", "run", "start"]
