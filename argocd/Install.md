# ArgoCD Installation

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo -n argocd --create-namespace
```
