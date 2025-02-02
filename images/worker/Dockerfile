ARG RUST_VERSION=1.80
ARG RUNNER_VERSION=oldstable-slim

FROM rust:${RUST_VERSION} AS builder

RUN USER=root cargo new --bin virtual-worker

WORKDIR /virtual-worker

COPY Cargo.toml Cargo.lock src/ ./

RUN cargo build --release

# Remove the .rs files created by cargo
RUN rm src/*.rs

COPY Cargo.toml Cargo.lock ./

COPY src/ ./src/

# Remove the dummy target directory created by cargo
RUN rm ./target/release/deps/virtual_worker*

# Build the application
RUN cargo build --release

# Create a new stage and copy the binary from the builder stage
FROM debian:${RUNNER_VERSION} AS runner

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

# Set the build argument for the app version number
ARG APP_VERSION=1.0

# Install OpenSSL
RUN apt-get update && apt-get --no-install-recommends install -y libssl-dev && rm -rf /var/lib/apt/lists/*

# Copy the binary from the builder stage
COPY --from=builder /virtual-worker/target/release/virtual-worker /app

# Set the environment variable for the app version number
ENV APP_VERSION=$APP_VERSION

USER appuser
# Run the application
CMD ["./virtual-worker"]