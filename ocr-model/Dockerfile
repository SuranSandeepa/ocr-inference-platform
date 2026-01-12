#Builder
FROM python:3.12-slim AS builder
RUN pip install poetry
WORKDIR /app
COPY pyproject.toml poetry.lock ./
# Install deps into the system path of the container
RUN poetry config virtualenvs.create false && poetry install --no-root --no-interaction

# Final Image
FROM python:3.12-slim
# Install Tesseract engine
RUN apt-get update && apt-get install -y tesseract-ocr libtesseract-dev && rm -rf /var/lib/apt/lists/*
WORKDIR /app
# Copy only the installed packages from the builder stage
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY model.py .
EXPOSE 8080
CMD ["python", "model.py"]