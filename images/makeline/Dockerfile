ARG GO_VERSION=1.22.5

FROM golang:${GO_VERSION}-alpine AS builder

WORKDIR /app

ARG APP_VERSION=1.0

COPY cosmosdb.go main.go mongodb.go orderqueue.go orders.go go.mod go.sum /app/

RUN go build -ldflags "-X main.version=$APP_VERSION" -o main .

FROM alpine:3.19.1 AS runner

ARG UID=1001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

ARG APP_VERSION=1.0

# Copy the build output from the builder container
COPY --from=builder /app/main .

# Expose port 3001 for the container
EXPOSE 3001

# Set the environment variable for the app version number
ENV APP_VERSION=$APP_VERSION

USER appuser

# Run the Go app when the container starts
CMD ["./main"]