# Argo Workflows

## Workflow

A workflow is a central resource in Argo Workflows that defines the workflow to be executed and stores the workflow’s state.

It consists of a specification that contains an entrypoint and a list of templates.

## Template

A template defines the instructions to execute in a workflow step.

A template can be one of the following types:

- Template definitions
  - Container - Run task inside container
  - Script - Similar to `Container` but allow to source the script
  - Resource - Allows direct manipulation of cluster resources
  - Suspend - Suspend the execution for duration or resume manually

- Template invocators
  - Steps
  - DAG (Direct Acyclic Graph) - Defines a directed acyclic graph of other templates

## Installation

### kubectl

- Install Argo Workflow of version **v3.7.9**.

  ```bash
  # Create namespace
  kubectl create ns argo
  kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.7.9/install.yaml
  ```

- Verify installation:

  ```bash
  kubectl get pods -n argo
  ```

- Change the authentication mode to `server` Authentication **(Not recommended for Production environments)**. A more secure option is to use the `client` authentication mode, which require clients to provide their Kubernetes bearer token.
[Doc Reference](https://argo-workflows.readthedocs.io/en/latest/argo-server-auth-mode/)

  ```bash
  kubectl patch deployment -n argo argo-server --type='json' -p='[
    {
      "op": "replace",
      "path": "/spec/template/spec/containers/0/args",
      "value": ["server","--auth-mode=server"]
    }
  ]'
  ```

- Grant Argo Server **admin-level** permissions for `argo` namespace & `default` namespace to create resources (pods, configmaps, etc..) in Kubernetes cluster via Workflow.

  ```bash
  kubectl create rolebinding argo-default-admin --clusterrole=admin --serviceaccount=argo:default -n argo
  kubectl create rolebinding argo-default-admin --clusterrole=admin --serviceaccount=default:default -n default
  ```

- Forward the Argo Server Web UI on port **2746**.

  ```bash
  kubectl -n argo port-forward deployment/argo-server 2746:2746
  ```

- Or make service `wf-argo-workflows-server` of type `NodePort` to expose on port **32746**.

  ```bash
  kubectl patch svc -n argo wf-argo-workflows-server --type='json' -p='[
    {
      "op": "replace",
      "path": "/spec/type",
      "value": "NodePort"
    },
    {
      "op": "add",
      "path": "/spec/ports/0/nodePort",
      "value": 32746
    }
  ]'
  ```

### Helm

```bash
helm repo add
helm fetch argo/argo-workflow --untar
```

Annotate CRDs:

```bash
kubectl annotate crd clusterworkflowtemplates.argoproj.io meta.helm.sh/release-namespace=argo --overwrite
kubectl annotate crd clusterworkflowtemplates.argoproj.io meta.helm.sh/release-name=wf --overwrite
kubectl annotate crd workflowartifactgctasks.argoproj.io meta.helm.sh/release-namespace=argo --overwrite
kubectl annotate crd workflowartifactgctasks.argoproj.io meta.helm.sh/release-name=wf --overwrite
kubectl annotate crd workfloweventbindings.argoproj.io meta.helm.sh/release-namespace=argo --overwrite
kubectl annotate crd workfloweventbindings.argoproj.io meta.helm.sh/release-name=wf --overwrite
kubectl annotate crd workflowtaskresults.argoproj.io meta.helm.sh/release-namespace=argo --overwrite
kubectl annotate crd workflowtaskresults.argoproj.io meta.helm.sh/release-name=wf --overwrite
kubectl annotate crd workflows.argoproj.io meta.helm.sh/release-namespace=argo --overwrite
kubectl annotate crd workflows.argoproj.io meta.helm.sh/release-name=wf --overwrite
kubectl annotate crd workflowtemplates.argoproj.io meta.helm.sh/release-namespace=argo --overwrite
kubectl annotate crd workflowtemplates.argoproj.io meta.helm.sh/release-name=wf --overwrite
kubectl annotate crd workflowtasksets.argoproj.io meta.helm.sh/release-namespace=argo --overwrite
kubectl annotate crd workflowtasksets.argoproj.io meta.helm.sh/release-name=wf --overwrite
kubectl annotate crd cronworkflows.argoproj.io meta.helm.sh/release-namespace=argo --overwrite
kubectl annotate crd cronworkflows.argoproj.io meta.helm.sh/release-name=wf --overwrite
```

Install without CRDs:

```bash
helm install wf . -n argo -f values.yaml
```

### Install Argo CLI

```bash
# Detect OS
ARGO_OS="darwin"
if [[ "$(uname -s)" != "Darwin" ]]; then
  ARGO_OS="linux"
fi

# Download the binary
curl -sLO "https://github.com/argoproj/argo-workflows/releases/download/v3.7.9/argo-$ARGO_OS-amd64.gz"

# Unzip
gunzip "argo-$ARGO_OS-amd64.gz"

# Make binary executable
chmod +x "argo-$ARGO_OS-amd64"

# Move binary to path
sudo mv "./argo-$ARGO_OS-amd64" /usr/local/bin/argo

# Test installation
argo version
```

### Teardown

Delete CRDs:

```bash
helm uninstall wf -n argo
kubectl delete crd workflowartifactgctasks.argoproj.io
kubectl delete crd workfloweventbindings.argoproj.io
kubectl delete crd workflowtaskresults.argoproj.io
kubectl delete crd workflows.argoproj.io
kubectl delete crd workflowtemplates.argoproj.io
kubectl delete crd workflowtasksets.argoproj.io
kubectl delete ns argo
```

## Create workflows

Create a workflow e.x. `sequence-workflow.yaml`.

Apply workflow with `argo`:

```bash
argo submit workflow/sequence-workflow.yaml -n argo
```

List workflows:

```bash
argo list -n argo
```
