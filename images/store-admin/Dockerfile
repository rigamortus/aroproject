ARG NODE_VERSION=18.20.4
ARG NGINX_VERSION=stable

FROM node:${NODE_VERSION}-alpine AS builder

WORKDIR /app

COPY package*.json ./


COPY babel.confif.js jsconfig.json vue.config.js public/ src/ nginx.conf ./

RUN npm install --ignore-scripts \
    && npm run build

FROM nginx:${NGINX_VERSION}-alpine-slim AS runner

ARG UID=1001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

COPY --from=builder /app/dist /usr/share/nginx/html

# Set the build argument for the app version number
ARG APP_VERSION=1.0

# Set the environment variable for the app version number
ENV APP_VERSION=$APP_VERSION

# Copy the nginx configuration template to the container
COPY nginx.conf /etc/nginx/conf.d/nginx.conf.template

# Update the nginx configuration to use the app version number
# and Copy the nginx configuration template to the container
RUN envsubst '${APP_VERSION}' < /etc/nginx/conf.d/nginx.conf.template > /etc/nginx/conf.d/default.conf

USER appuser

# Expose the port the app listens on
EXPOSE 8081

# Start the app
CMD ["nginx", "-g", "daemon off;"]