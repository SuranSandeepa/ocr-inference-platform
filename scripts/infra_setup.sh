#!/bin/bash

set -e

echo "Starting Minikube Cluster"
minikube start --driver=docker --memory=4096 --cpus=2

echo "Configuring Helm Repositories"
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update


echo "Deploying ArgoCD"
kubectl create namespace argocd || true
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --set server.resources.limits.memory=256Mi \
  --set controller.resources.limits.memory=512Mi \
  --wait

echo "Deploying Prometheus & Grafana"
kubectl create namespace monitoring || true
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.resources.limits.memory=1024Mi \
  --set grafana.resources.limits.memory=512Mi \
  --wait


echo "Infrastructure Setup Complete!"

helm list -A
echo ""
kubectl get pods -A