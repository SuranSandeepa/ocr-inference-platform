# Builder Stage
FROM python:3.12-slim AS builder
RUN pip install poetry
WORKDIR /app
COPY pyproject.toml poetry.lock ./
# We skip virtualenv because we are inside a container
RUN poetry config virtualenvs.create false && poetry install --no-root --no-interaction

# Final Image Stage
FROM python:3.12-slim
# Create a non-root user
RUN addgroup --system appgroup && adduser --system --group worker
WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy app code and set ownership
COPY --chown=worker:appgroup api-gateway.py .

USER worker
EXPOSE 8001
CMD ["python", "api-gateway.py"]