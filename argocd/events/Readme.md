# ArgoCD Events

## Installation

```bash
# Create the namespace
kubectl create namespace argo-events

# Deploy Argo Events SA, ClusterRoles, and Controller for Sensor, EventBus, and EventSource
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/namespace-install.yaml

# Install with a validating admission controller
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install-validating-webhook.yaml

# Deploy EventBus
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
```
