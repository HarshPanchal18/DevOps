# [Headelamp](https://headlamp.dev/) - An easy-to-use and extensible web UI for Kubernetes

## In-cluster [installation](https://headlamp.dev/docs/latest/installation/in-cluster/)

- Install helm charts:

```bash
kubectl create ns headlamp # Create a separate namespace.
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/ # Add custom repo to your local helm repositories
helm install my-headlamp headlamp/headlamp --namespace kube-system # Install headlamp via helm
```

- Change the `my-headlamp` service type to **NodePort** in order to access Headlamp dashboard.

- Generate ID token through following command.

```bash
kubectl create token my-headlamp --namespace headlamp
```
