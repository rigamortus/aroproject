ARG RUST_VERSION=1.80.0
ARG DEBIAN_VERSION=bookworm-slim

FROM rust:${RUST_VERSION} AS builder

# Create a new Rust binary project
RUN USER=root cargo new --bin product-service

# Set the working directory
WORKDIR /product-service

# Copy the source files to the container
COPY -r Cargo.* config.yml crates/ src/ rule_engine.wit ./

# Build the application
RUN cargo build --release

# Create a non-root user in the builder stage
ARG UID=1001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Create a new stage and copy the binary from the builder stage
FROM debian:${DEBIAN_VERSION} AS runner

# Set the working directory
WORKDIR /app

# Create the same non-root user in the runner stage
ARG UID=1001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Set the build argument for the app version number
ARG APP_VERSION=1.0

# Not ideal but needed to execute health checks in docker-compose
RUN apt-get update && apt-get --no-install-recommends install -y wget libssl-dev && rm -rf /var/lib/apt/lists/*

# Copy the binary from the builder stage
COPY --from=builder /product-service/target/release/product-service /app

# Set the environment variable for the app version number
ENV APP_VERSION=$APP_VERSION

# # Expose the port the app listens on
# EXPOSE 8080

# Change to non-root user
USER appuser

# Run the application
CMD ["./product-service"]