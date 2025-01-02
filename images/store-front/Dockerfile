ARG NODE_VERSION=18.20.4
FROM node:${NODE_VERSION}-alpine AS builder

ENV NODE_ENV=production

WORKDIR /app

COPY package*.json ./

COPY . .

RUN npm install \
    && npm run build

ARG NGINX_VERSION=stable

ARG UID=1000
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

FROM nginx:${NGINX_VERSION}-alpine-slim AS runner

COPY --from=builder /app/dist /usr/share/nginx/html

ARG APP_VERSION=1.0

# Set the environment variable for the app version number
ENV APP_VERSION=$APP_VERSION

# Copy the nginx configuration template to the container
COPY nginx.conf /etc/nginx/conf.d/nginx.conf.template

# Update the nginx configuration to use the app version number
# and Copy the nginx configuration template to the container
RUN envsubst '${APP_VERSION}' < /etc/nginx/conf.d/nginx.conf.template > /etc/nginx/conf.d/default.conf

USER appuser

EXPOSE 8080

# Start the app
CMD ["nginx", "-g", "daemon off;"]
