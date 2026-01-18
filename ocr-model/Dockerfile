# Builder Stage
FROM python:3.12-slim AS builder
RUN pip install poetry
WORKDIR /app
COPY pyproject.toml poetry.lock ./
# We set virtualenvs.create to false because we are inside a container
RUN poetry config virtualenvs.create false && poetry install --no-root --no-interaction

# Final Image Stage
FROM python:3.12-slim
# 1. Install Tesseract OCR engine and create a non-root user for security
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    && rm -rf /var/lib/apt/lists/* \
    && addgroup --system appgroup && adduser --system --group worker

WORKDIR /app

# 2. Copy the installed Python dependencies from the builder stage
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# 3. Copy the model logic and ensure the worker user owns the files
COPY --chown=worker:appgroup model.py .

# 4. Switch to the non-root user to follow security best practices
USER worker

# KServe and our metrics server use port 8080 by default
EXPOSE 8080
CMD ["python", "model.py"]

