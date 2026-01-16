
# 01) Local Development 

The project began with setting up the development environment on Ubuntu. The core objective was to get the KServe model service and the FastAPI gateway talking to each other locally before moving to containers.

## 1.1) System Dependencies Installation
The OCR service relies on the Tesseract engine to perform text extraction from images.

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

To prepare the environment and dependencies for the KServe model. \
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

To prepare the FastAPI gateway that handles external image uploads. \
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

## 2.4) Image Distribution
To prepare for Kubernetes deployment, the local images were tagged and pushed to a remote repository on Docker Hub. This makes the images accessible to the Minikube cluster.

# 03) Infrastructure Setup
With the application successfully containerized and images pushed to the cloud, the focus shifted to building a production-grade platform. This phase involved setting up a local Kubernetes cluster and deploying industry-standard tools for GitOps (ArgoCD) and Observability (Prometheus & Grafana) using the Helm package manager.

## 3.1) Kubernetes Cluster Orchestration
We utilized Minikube to simulate a real-world Kubernetes environment on a local machine. To ensure the cluster could handle multiple heavy management tools, we specifically provisioned it with increased resources.

## 3.2) Automated Infrastructure with Helm
Instead of manual YAML manifests, we adopted Helm to manage the lifecycle of our platform tools. Helm allows for "Infrastructure as Code," where complex software stacks are installed as single packages (Charts).

We automated the entire setup through a script named infra_setup.sh, which performs the following:

Repository Syncing: Connects to public Helm (Argo and Prometheus-community).

Idempotent Deployment: Uses helm upgrade --install to ensure the script can be run multiple times without causing errors or duplicate installs.

Resource Optimization: Overrides default settings to prevent the monitoring tools from consuming all available system memory.

## 3.3) Tooling & Observability Stack

ArgoCD: Installed in the argocd namespace to facilitate Declarative GitOps. It monitors our Git repository and automatically syncs changes to the cluster.

Prometheus: Deployed to scrape and store real-time metrics from our OCR services.

Grafana: Deployed alongside Prometheus to provide a visual dashboard for monitoring system health.

![alt text](image-1.png)

![alt text](image-2.png)






![alt text](image-3.png)

![alt text](image-4.png)




