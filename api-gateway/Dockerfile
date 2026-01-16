# Builder Stage
FROM python:3.12-slim AS builder
RUN pip install poetry
WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.create false && poetry install --no-root --no-interaction

# Final Image Stage
FROM python:3.12-slim
# Create a non-root user for security
RUN addgroup --system appgroup && adduser --system --group worker
WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application code and change ownership to our new user
COPY --chown=worker:appgroup api-gateway.py .

# Switch to the non-root user
USER worker

EXPOSE 8001
CMD ["python", "api-gateway.py"]