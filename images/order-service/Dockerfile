ARG NODE_VERSION=20.18-alpine3.20

FROM node:${NODE_VERSION} AS builder

# Set the working directory to /app
WORKDIR /app

# Set the build argument for the app version number
ARG APP_VERSION=1.0

# Copy package.json and package-lock.json to the container
COPY package*.json ./

# Install app dependencies
RUN npm install --ignore-scripts

# Copy the rest of the app source code to the container
COPY . .

FROM node:${NODE_VERSION} AS runner

ARG UID=1001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

WORKDIR /app

# Copy only the necessary files from the build stage
COPY --from=builder /app .

ARG APP_VERSION=1.0

# Install only production dependencies
RUN npm install --ignore-scripts --production

# Expose the port the app listens on
EXPOSE 3000

# Set the environment variable for the app version number
ENV APP_VERSION=$APP_VERSION

USER appuser

# Start the app
CMD [ "npm", "start" ]