# Multi-stage
# 1) Node image for building frontend assets
# 2) Nginx stage to serve frontend assets

# Name the node stage "builder"
FROM node:18.16 AS builder
# Set working directory
WORKDIR /app
# Copy all files from current directory to working dir in image
COPY . .
# Install node modules and build assets
RUN yarn config set registry https://registry.npmjs.org && \
    yarn install && yarn build

# Nginx state for serving content
FROM nginx:alpine
# Set working directory to nginx asset directory
WORKDIR /usr/share/nginx/html
# Remove default nginx static assets
RUN rm -rf ./*
# Copy static assets from builder stage
COPY --from=builder /app/build .
# Nginx template and environment variables settings
COPY --from=builder /app/nginx/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY --from=builder /app/nginx/50-nginx-env.sh /docker-entrypoint.d/50-nginx-env.sh
RUN chmod +x /docker-entrypoint.d/50-nginx-env.sh
# Containers run nginx with global directives and daemon off
CMD ["nginx", "-g", "daemon off;"]
