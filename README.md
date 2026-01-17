# The OCR System Architecture

```
This architecture follows a Declarative GitOps pattern. I manage application code with Poetry
and package it into secure, non-root Docker images pushed to Docker Hub.
Infrastructure is managed as code using Helm Charts stored in GitHub. 
ArgoCD acts as the controller, synchronizing the Minikube cluster state with GitHub.
Finally, Prometheus scrapes inference metrics from the model,
providing real-time observability via Grafana dashboards.
```

<img width="938" height="632" alt="image" src="https://github.com/user-attachments/assets/c1383604-fcc4-4826-8220-37221ccf6ba1" />
