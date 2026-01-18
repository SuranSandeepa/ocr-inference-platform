#!/bin/bash

#----------------------
# Author: Suran Sandeepa
# Description: Automate the build and testing of Docker images locally
# Date: 12 Jan 2026
#---------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Root Directory identified as: $ROOT_DIR"

fuser -k 8001/tcp 2>/dev/null || true
fuser -k 8080/tcp 2>/dev/null || true

# 3. Patch the URL in api-gateway for Docker Networking
# use | as a delimiter because the URL contains forward slashes /
echo "Updating API Gateway configuration..."
sed -i "s|localhost:8080|ocr-model-container:8080|g" "$ROOT_DIR/api-gateway/api-gateway.py"

# 4. Build the images using the ROOT_DIR variable
echo "Building OCR Model Image..."
docker build -t ocr-model:v1 "$ROOT_DIR/ocr-model"

echo "Building API Gateway Image..."
docker build -t api-gateway:v1 "$ROOT_DIR/api-gateway"

# 5. Create a bridge network
docker network create ocr-network || true

# 6. Stop and remove old containers if they exist to prevent name conflicts
docker rm -f ocr-model-container api-gateway-container || true

# 7. Run the containers
echo "Launching containers..."
docker run -d --name ocr-model-container --network ocr-network ocr-model:v1
docker run -d --name api-gateway-container --network ocr-network -p 8001:8001 api-gateway:v1

echo "Containers are running! Test via Postman on port 8001."