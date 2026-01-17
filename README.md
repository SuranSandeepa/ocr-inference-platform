# The OCR System Architecture

```
This architecture follows a Declarative GitOps pattern. I manage application code with Poetry
and package it into secure, non-root Docker images pushed to Docker Hub.
Infrastructure is managed as code using Helm Charts stored in GitHub. 
ArgoCD acts as the controller, synchronizing the Minikube cluster state with GitHub.
Finally, Prometheus scrapes inference metrics from the model,
providing real-time observability via Grafana dashboards.
```

![alt text](OCR.drawio.png)
