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

## Calico daemonset create error path "/var/run/calico" is mounted on "/" but it is not a shared mount

This usually comes from Kubernetes or container runtimes (like `containerd` or `kubelet`) when Calico (CNI plugin) tries to mount its socket or volume into pods but the parent mount (/) isn’t marked as **“shared”**.

### What’s Happening

- Calico (or any CNI) mounts `/var/run/calico` inside pods or containers.
- For that to work properly, the parent mount (/) must be shared (so that mounts made inside one namespace are visible to others).
- On your system, / is likely private or slave, meaning mounts aren’t propagated between namespaces.

### Verify Mount Type

Run this on the node:

```bash
findmnt -o TARGET,PROPAGATION /
```

Expected output (good):

```bash
TARGET PROPAGATION
/      shared
```

If you see:

```bash
TARGET PROPAGATION
/      private
```

— that’s the root of the problem.

### Fix (Temporary & Permanent)

1. Temporary Fix (until reboot)

    You can make / a shared mount by running:

    ```bash
    sudo mount --make-shared /
    ```

    Then verify again:

    ```bash
    findmnt -o TARGET,PROPAGATION /
    ```

    Now it should say shared. This only lasts until the next reboot.

2. Permanent Fix

    Add this line to your system startup configuration, depending on your OS.

    For `systemd`-based systems (most modern Linux):

    Create or edit:

    ```bash
    sudo nano /etc/systemd/system/shared-mount.service
    ```

    Add:

    ```conf
    [Unit]
    Description=Make root mount shared
    DefaultDependencies=no
    Before=local-fs.target

    [Service]
    Type=oneshot
    ExecStart=/bin/mount --make-shared /

    [Install]
    WantedBy=local-fs.target
    ```

    Then enable it:

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable shared-mount.service
    ```

### After Fixing, Restart `kubelet` and `Calico` pods (or DaemonSet)

```bash
sudo systemctl restart kubelet
kubectl rollout restart daemonset calico-node -n kube-system
```

Check Calico pods:

```bash
kubectl get pods -n kube-system -o wide | grep calico
```

They should come up Running without that warning.
