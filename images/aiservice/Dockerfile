ARG PY_VERSION=3.13.0rc2


FROM python:${PY_VERSION}-alpine3.19 AS base

WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

RUN apk update && \
    apk add --no-cache g++ gcc libffi-dev musl-dev

RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY main.py routers/ skills/ ./


FROM python:${PY_VERSION}-alpine3.19 AS runner

ARG APP_VERSION=1.0

# Set the working directory to /app
WORKDIR /app

# Copy only the necessary files from the build stage
COPY --from=base /app /app

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser


USER appuser

# Expose port 5001 for the FastAPI application
EXPOSE 5001

# Set the environment variable for the app version number
ENV APP_VERSION=$APP_VERSION

# Start the FastAPI application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5001"]
