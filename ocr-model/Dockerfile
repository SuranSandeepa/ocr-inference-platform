# Builder Stage
FROM python:3.12-slim AS builder
RUN pip install poetry
WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.create false && poetry install --no-root --no-interaction

# Final Image Stage
FROM python:3.12-slim
# 1. Install Tesseract and create non-root user
RUN apt-get update && apt-get install -y tesseract-ocr libtesseract-dev \
    && rm -rf /var/lib/apt/lists/* \
    && addgroup --system appgroup && adduser --system --group worker

WORKDIR /app

# 2. Copy dependencies
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# 3. Copy code and fix permissions
COPY --chown=worker:appgroup model.py .

# 4. Switch to non-root user
USER worker

EXPOSE 8080
CMD ["python", "model.py"]