# Debugging and Troubleshootings in Kubernetes

## Delete namespace stuck in `Terminating` state

```bash
(
NAMESPACE=na-data
kubectl proxy &
kubectl get namespace $NAMESPACE -o json |jq '.spec = {"finalizers":[]}' >temp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json 127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize
)
```

## Delete PV/PVC stuck in `Terminating` state

```bash
kubectl patch pv $PVNAME -p '{"metadata":{"finalizers":null}}'
```

## Check for remaining objects in a namespace and delete it, if any

```bash
kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n $NAMESPACE
```
