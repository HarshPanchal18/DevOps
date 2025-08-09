# Kind - Kubernetes IN Docker

Kind is a tool for running local Kubernetes clusters using Docker container "nodes". It is primarily designed for testing Kubernetes itself, but can also be used to run local clusters for development and testing purposes.

A config file for creating a kind cluster can be used to specify the number of nodes, roles, and networking configurations.

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
# - role: worker
networking:
  disableDefaultCNI: true
  podSubnet: "192.168.0.0/16"
```

- Create a kind cluster.

    ```bash
    kind create cluster --config kind-config.yml --name=multinode
    ```

- List clusters.

    ```bash
    kind get clusters
    ```

- Delete a kind cluster.

    ```bash
    kind delete cluster --name=multinode
    ```

- Get the kubeconfig for the kind cluster.

    ```bash
    kind get kubeconfig --name=multinode
    ```

- Get the kubeconfig for the kind cluster and save it to a file.

    ```bash
    kind get kubeconfig --name=multinode > kubeconfig-multinode
    ```

- Use the kubeconfig file to access the kind cluster.

    ```bash
    export KUBECONFIG=kubeconfig-multinode
    kubectl get nodes
    ```

- Create a kind cluster with a specific image.

    ```bash
    kind create cluster --image=kindest/node:v1.23.0 --name=multinode
    ```

- Create a kind cluster with a specific version of Kubernetes.

    ```bash
    kind create cluster --image=kindest/node:v1.23.0 --name=multinode --kubeconfig=kubeconfig-multinode
    ```

- Create a kind cluster with a specific version of Kubernetes and a specific network configuration.

    ```bash
    kind create cluster --image=kindest/node:v1.23.0 --name=multinode --config kind-config.yml
    ```

- Create a kind cluster with a specific version of Kubernetes and a specific network configuration and save the kubeconfig to a file.

    ```bash
    kind create cluster --image=kindest/node:v1.23.0 --name=multinode --config kind-config.yml --kubeconfig=kubeconfig-multinode
    ```

- Create a kind cluster with a specific version of Kubernetes and a specific network configuration and save the kubeconfig to a file in a specific directory.

    ```bash
    kind create cluster --image=kindest/node:v1.23.0 --name=multinode --config kind-config.yml --kubeconfig=/path/to/kubeconfig/kubeconfig-multinode
    ```

- Create a kind cluster with a specific version of Kubernetes and a specific network configuration and save the kubeconfig to a file in a specific directory and set the KUBECONFIG environment variable.

    ```bash
    kind create cluster --image=kindest/node:v1.23.0 --name=multinode --config kind-config.yml --kubeconfig=/path/to/kubeconfig/kubeconfig-multinode
    export KUBECONFIG=/path/to/kubeconfig/kubeconfig-multinode
    kubectl get nodes
    ```
