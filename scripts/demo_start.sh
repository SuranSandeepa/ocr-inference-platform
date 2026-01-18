#!/bin/bash

#-------------------------------------------------------------------------
# OCR Project Full Stack Demo Script
# Purpose: Start Minikube, check all pods, and setup port-forwarding for:
#          - API Gateway
#          - Grafana (Monitoring)
#          - Prometheus (Metrics)
#          - ArgoCD (GitOps)
#-------------------------------------------------------------------------

echo "🚀 Preparing the Full OCR System Stack for Demo..."

# 1. Ensure Minikube is running
if ! minikube status > /dev/null 2>&1; then
    echo "🏗️  Starting Minikube..."
    minikube start --driver=docker --memory=4096 --cpus=2
else
    echo "✅ Minikube is already active."
fi

# 2. Wait for Core Application pods to be ready
echo "⏳ Waiting for Application pods (OCR Model & Gateway)..."
kubectl wait --for=condition=ready pod -l app=ocr-model --timeout=90s
kubectl wait --for=condition=ready pod -l app=api-gateway --timeout=90s

# 3. Wait for Infrastructure pods (ArgoCD & Monitoring)
echo "⏳ Waiting for Infrastructure pods (ArgoCD & Monitoring)..."
kubectl wait --for=condition=ready pod -n argocd -l app.kubernetes.io/name=argocd-server --timeout=90s
kubectl wait --for=condition=ready pod -n monitoring -l app.kubernetes.io/name=grafana --timeout=90s

# 4. Clear any old port-forwards
echo "🧹 Clearing old connections..."
pkill -f "port-forward" || true
sleep 2

# 5. Retrieve Passwords for the presentation
echo "🔑 Retrieving Access Credentials..."
GRAFANA_PASS="prom-operator"
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# 6. Setup Port-Forwarding in the background
echo "🔗 Setting up tunnels for all services..."

# API Gateway (Demo Endpoint)
kubectl port-forward svc/api-gateway-service 8001:8001 > /dev/null 2>&1 &

# Grafana (Monitoring Dashboard)
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80 > /dev/null 2>&1 &

# Prometheus (Metrics Targets)
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090 > /dev/null 2>&1 &

# ArgoCD UI (GitOps Dashboard)
kubectl port-forward svc/argocd-server -n argocd 8081:443 > /dev/null 2>&1 &

sleep 5

echo "--------------------------------------------------------"
echo "🎯 ALL SYSTEMS GO - DEMO READY"
echo "--------------------------------------------------------"
echo "🔄 ARGO CD (GitOps):"
echo "   URL: http://localhost:8081"
echo "   User: admin"
echo "   Pass: $ARGOCD_PASS"
echo ""
echo "🖥️  GRAFANA (Monitoring):"
echo "   URL: http://localhost:3000"
echo "   User: admin"
echo "   Pass: $GRAFANA_PASS"
echo ""
echo "📈 PROMETHEUS (Targets):"
echo "   URL: http://localhost:9090/targets"
echo ""
echo "📸 API TEST COMMAND:"
echo "   curl -X POST http://localhost:8001/gateway/ocr -F 'image_file=@test.jpg'"
echo "--------------------------------------------------------"
echo "Keep this terminal open. Press Ctrl+C to stop the tunnels."

# Keep the script running
wait