# ArgoCD Installation

## Using manifests

1. Create a namespace and deploy ArgoCD inside namespace.

    ```bash
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ```

2. Expose `argocd-server` service to access ArgoCD server.
    - Change type to either LoadBalancer or NodePort
    - Or do port forwarding

## Using Helm

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace
```

## Get admin password

```bash
kubectl get secrets -n argocd argocd-initial-admin-secret -ojsonpath="{.data.password}" | base64 --decode
```

Or if you're into a `argocd-server` pod,

```bash
argocd admin initial-password -n argocd
```

## Deploy Kubernetes dashboard

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

- Create a token for dashboard access:

```bash
kubectl -n kubernetes-dashboard create token admin-user
```

- `admin-user` Service Account

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
    name: admin-user
    namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
    name: admin-user
roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: cluster-admin
subjects:
    - kind: ServiceAccount
      name: admin-user
      namespace: kubernetes-dashboard
```
