
# 01) Local Development 

The environment was first prepared by installing the Tesseract OCR engine and Poetry package manager. We utilized Poetry to create isolated virtual environments, ensuring dependency consistency. After adjusting the service configuration for local networking (localhost), we verified the system by sending an image through the API Gateway, which successfully proxied the request to the KServe Model Service, returning the extracted text in JSON format.

## 1.1) System Dependencies Installation

The OCR service requires the Tesseract engine

```
# Update package list and install Tesseract OCR engine
sudo apt update
sudo apt install -y tesseract-ocr libtesseract-dev
```

## 1.2) Python Environment Setup

The project uses Poetry for deterministic dependency management.

```
# Install Poetry using the official installer
curl -sSL https://install.python-poetry.org | python3 -

# Add Poetry to the system path (if not automatically added)
export PATH="$HOME/.local/bin:$PATH"

# Reload shell config
source ~/.bashrc

# Verify Poetry now works
which poetry
poetry --version

-s → silent (no progress bar)
-S → show errors if they happen
-L → follow redirects
```

## 1.3) OCR Model Service Initialization

To prepare the environment and dependencies for the KServe model.
/ocr-devops-assignment/ocr-model

```
# Attempted installation (Initially failed)
poetry install

# Error encountered: 
# "Readme path ... README.md does not exist."
# Reason: Poetry expects a README file for packaging by default.

# Resolution:
touch README.md
poetry install --no-root

# Start the service
poetry run python model.py

```

## 1.4) API Gateway Service Initialization

To prepare the FastAPI gateway that handles external image uploads.
ocr-devops-assignment/api-gateway

```
# Prepare environment
touch README.md
poetry install --no-root

# Start the service
poetry run python api-gateway.py
```

## 1.5) Connectivity Configuration & Troubleshooting

Resolving service-to-service communication errors.

Error Encountered in Postman: Max retries exceeded with url: /v2/models/ocr-model/infer (Caused by NameResolutionError)

The code was configured to look for a Docker container named ocr-model-container. Changed the KSERVE_URL in api-gateway.py from http://ocr-model-container:8080/... to http://localhost:8080/....

## 1.6) Functional Testing

Postman Configuration:
Method: POST
URL: http://localhost:8001/gateway/ocr
Body Type: form-data
Key: image_file

![alt text](image.png)

# 02) Containerization
After verifying the code locally, the next phase involved packaging the applications into Docker images. This process ensures that the services run consistently across different environments (Development, Staging, and Production) by bundling the code, runtime, and system-level dependencies together.

## 2.1) Dockerfile Design Strategy
We created specific Dockerfiles for both the API Gateway and the OCR Model using a multi-stage build approach.

## 2.2) Automation with Bash Scripting
To streamline the build and deployment process, a bash script named build_images.sh was created in the scripts/ directory. This script automates several manual steps:

Configuration Patching: It automatically updates the api-gateway.py to use the internal Docker container name (ocr-model-container) instead of localhost.

Resource Cleanup: It stops and removes any existing containers and clears port 8001 to prevent "address already in use" errors.

Image Construction: It builds both images using absolute paths to ensure the script can be run from any directory.

Network Orchestration: It creates a dedicated Docker bridge network (ocr-network) to allow the two containers to communicate via DNS.

## 2.3) Troubleshooting & Resolution
During this phase, we encountered a Port Conflict error. The Docker daemon was unable to bind the API Gateway to port 8001 because the local FastAPI service (started in Phase 1) was still occupying that port.
Utilized the ``` fuser -k 8001/tcp ``` command within the automation script to identify and terminate any processes currently using the required port before launching the containers.

## 2.4) Image Distribution (Docker Hub)
To prepare for Kubernetes deployment, the local images were tagged and pushed to a remote repository on Docker Hub. This makes the images accessible to the Minikube cluster.