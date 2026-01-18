#!/bin/bash

#----------------------
# Author: Suran Sandeepa
# Description: Build and push to a single private repository using tags
#---------------------

DOCKER_USER="suranpickme"
REPO_NAME="ocr-inference-platform"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Using Root Directory: $ROOT_DIR"

# 1. Build images with specific tags for the same repo
echo "🚀 Building OCR Model..."
docker build -t $DOCKER_USER/$REPO_NAME:ocr-model-v3 "$ROOT_DIR/ocr-model"

echo "🚀 Building API Gateway..."
docker build -t $DOCKER_USER/$REPO_NAME:api-gateway-v3 "$ROOT_DIR/api-gateway"

# 2. Push images
echo "☁️  Pushing to private repository: $REPO_NAME..."
docker push $DOCKER_USER/$REPO_NAME:ocr-model-v3
docker push $DOCKER_USER/$REPO_NAME:api-gateway-v3

echo "✅ Images pushed to $DOCKER_USER/$REPO_NAME"