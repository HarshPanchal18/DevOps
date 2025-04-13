# Kubernetes controller for GitHub Actions self-hosted runners / Setting up Self hosted runners for GitHub Actions on Kubernetes cluster

* *[GitHub Actions Reference Repository](https://github.com/actions/actions-runner-controller/)*

## Install [cert-manager](https://cert-manager.io/docs/installation/) on kubernetes

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.yaml
```

## Install [ARC](https://github.com/actions/actions-runner-controller/blob/master/docs/installing-arc.md) (Actions Runner Controller)

```bash
kubectl apply -f https://github.com/actions/actions-runner-controller/releases/download/v0.25.2/actions-runner-controller.yaml
```

## Authenticate to GitHub [API](https://github.com/actions/actions-runner-controller/blob/master/docs/authenticating-to-the-github-api.md)

## Create Kubectl secret for PAT

```bash
kubectl create secret generic github-pat \
    -n github-runner \
    --from-literal=github_token=PAT
```

## Verify that pods are running

## Deploying runners with [RunnerDeployments](https://github.com/actions/actions-runner-controller/blob/master/docs/deploying-arc-runners.md) and Adding runners to a [repository](https://github.com/actions/actions-runner-controller/blob/master/docs/choosing-runner-destination.md)

```yaml
# runnerDeployment.yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: example-runnerdeploy
spec:
  replicas: 2
  template:
    spec:
      repository: HarshPanchal18/HarshPanchal18
```

## Apply and verify the deployment

```bash
kubectl apply -f runnerDeployment.yaml
kubectl get runners
```
