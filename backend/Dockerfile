FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine
WORKDIR /app
# Create uploads dir with correct ownership BEFORE switching user
RUN mkdir -p uploads && \
    addgroup -S appgroup && \
    adduser  -S appuser -G appgroup && \
    chown -R appuser:appgroup /app
COPY --from=deps --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --chown=appuser:appgroup . .
USER appuser
EXPOSE 9000
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:9000/api/health || exit 1
CMD ["node","index.js"]