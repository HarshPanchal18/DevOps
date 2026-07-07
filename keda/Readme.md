# KEDA (Kubernetes Event Driven Autoscaling)

With KEDA, you can drive the scaling of any container in Kubernetes based on the number of events needing to be processed.

KEDA is a `single-purpose` and `lightweight` component that can be added into any Kubernetes cluster. KEDA works alongside standard Kubernetes components like the `Horizontal Pod Autoscaler` and can extend functionality without overwriting or duplication.

With KEDA, you can explicitly map the apps you want to use event-driven scale, with other apps continuing to function. This makes KEDA a flexible and safe option to run alongside any number of any other Kubernetes applications or frameworks.

## Installations

### Helm

Add official Helm repository.

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
```

Install KEDA.

```bash
helm install keda kedacore/keda --namespace keda --create-namespace
```

Verify deployment by checking the `keda` namespace.

```bash
kubectl get pods -n keda
```

### Standalone

1. Download the CRD YAMLs from GitHub [release](https://github.com/kedacore/keda/releases)

2. Apply the CRDs to your cluster. Replace 2.x.x with the specific version number you downloaded.

    ```bash
    kubectl apply -f keda-2.x.x.-crds.yaml
    ```

3. If it says that limit is exceeded,

    ```bash
    kubectl create -f keda-2.x.x.-crds.yaml
    ```

    OR

    ```bash
    kubectl apply -f keda-2.x.x.-crds.yaml --server-side
    ```

### Teardown

To uninstall KEDA, use the following Helm command:

```bash
helm uninstall keda –namespace keda
```

If you also want to delete the keda namespace,

```bash
kubectl delete namespace keda
```

Uninstalling with Helm is efficient and keeps your cluster clean, especially if you’re testing configurations or upgrading to a new KEDA version.

You can remove finalizers with the following command:

```bash
kubectl patch scaledobject <resource-name> -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch scaledjob <resource-name> -p '{"metadata":{"finalizers":null}}' --type=merge
```

Replace <resource-name> with the specific name of each resource. Removing finalizers ensures that these resources are fully removed, preventing any unintended orphaned resources in your cluster.

## Application

- You can find triggers supported by KEDA here [scalers](https://keda.sh/docs/2.17/scalers/).
