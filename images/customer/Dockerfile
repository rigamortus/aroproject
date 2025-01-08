ARG RUST_VERSION=1.80
ARG RUNNER_VERSION=bookworm-slim

FROM rust:${RUST_VERSION} AS builder

RUN USER=root cargo new --bin virtual-customer

# Create a new directory for our application
WORKDIR /virtual-customer

# Copy the Cargo.toml and Cargo.lock files to the container
COPY Cargo.toml Cargo.lock ./

# Build the dependencies and cache them
RUN cargo build --release

# Remove the .rs files created by cargo
RUN rm src/*.rs

# Remove the dummy target directory created by cargo
RUN rm ./target/release/deps/virtual_customer*

# Build the application
RUN cargo build --release

# Create a new stage and copy the binary from the builder stage
FROM debian:${RUNNER_VERSION} AS runner

WORKDIR /app

# Set the build argument for the app version number
ARG APP_VERSION=1.0

ARG UID=1001
RUN apt-get update \
    && apt-get --no-install-recommends install -y libssl-dev \
    && rm -rf /var/lib/apt/lists/* \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Copy the binary from the builder stage
COPY --from=builder /virtual-customer/target/release/virtual-customer /app

# Set the environment variable for the app version number
ENV APP_VERSION=$APP_VERSION

USER appuser
# Run the application
CMD ["./virtual-customer"]