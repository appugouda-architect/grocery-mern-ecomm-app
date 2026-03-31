# ── Stage 1: build ──────────────────────────────────────────────
FROM node:18-alpine AS build
ARG VITE_BACKEND_URL
ENV VITE_BACKEND_URL=$VITE_BACKEND_URL
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN rm -f .env .env.*
RUN npm run build

# ── Stage 2: serve ──────────────────────────────────────────────
FROM nginx:1.25-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost/ || exit 1
CMD ["nginx","-g","daemon off;"]