FROM node:alpine AS build

# Declare build time environment variables
ARG REACT_APP_NODE_ENV
ARG REACT_APP_SERVER_BASE_URL
ARG VITE_BACKEND_URL

# Set default values for environment variables
ENV REACT_APP_NODE_ENV=$REACT_APP_NODE_ENV
ENV REACT_APP_SERVER_BASE_URL=$REACT_APP_SERVER_BASE_URL
ENV VITE_BACKEND_URL=$VITE_BACKEND_URL

# Build App
WORKDIR /app
COPY package*.json ./
RUN npm install
# Copy everything except .env file to avoid overriding build args
COPY . .
# Remove .env file if it exists to ensure build args take precedence
RUN rm -f .env || true
RUN npm run build

# Serve with Nginx
FROM nginx:1.23-alpine
# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf
WORKDIR /usr/share/nginx/html
RUN rm -rf *
COPY --from=build /app/dist .
EXPOSE 80
ENTRYPOINT [ "nginx", "-g", "daemon off;" ]