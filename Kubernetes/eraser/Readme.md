# Eraser

Eraser aims to provide a simple way to determine the state of an image, and delete it if it meets the specified criteria.

## Install

```bash
kubectl apply -f https://raw.githubusercontent.com/eraser-dev/eraser/v1.4.1/deploy/eraser.yaml
```

Verify pods:

```bash
kubectl get pods -n eraser-system
```

Eraser will schedule eraser pods to each node in the cluster, and each pod will contain 3 containers: `collector`, `scanner`, and `remover` that will run to completion.

The collector container sends the list of all images to the scanner container, which scans and reports non-compliant images to the remover container for removal of images that are non-running. Once all pods are `completed`, they will be automatically cleaned up.

If you want to remove all the images periodically, you can skip the scanner container by setting the `components.scanner.enabled` value to `false` using the configmap. In this case, each collector pod will hold 2 containers: `collector` and `remover`.

## Simulate

Deploy below daemonset with an image of a critical vulnerability (alpine:3.7.3).

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: alpine
spec:
  selector:
    matchLabels:
      app: alpine
  template:
    metadata:
      labels:
        app: alpine
    spec:
      containers:
      - name: alpine
        image: docker.io/library/alpine:3.7.3
EOF
```

View pod status:

```bash
kubectl get pods
```

Above deployed pods will go into `CrashLoopBackOff`. This is expected behavior from the `alpine` image.

Delete the daemonset:

```bash
kubectl delete daemonset alpine
```

Now list alpine image on each node one by one:

```bash
ctr -n k8s.io images ls | grep alpine
```

Output will be similar

```bash
docker.io/library/alpine:3.7.3                                                                             application/vnd.docker.distribution.manifest.list.v2+json sha256:8421d9a84432575381bfabd248f1eb56f3aa21d9d7cd2511583c68c9b7511d10 2.0 MiB   linux/386,linux/amd64,linux/arm/v6,linux/arm64/v8,linux/ppc64le,linux/s390x  io.cri-containerd.image=managed
docker.io/library/alpine@sha256:8421d9a84432575381bfabd248f1eb56f3aa21d9d7cd2511583c68c9b7511d10           application/vnd.docker.distribution.manifest.list.v2+json sha256:8421d9a84432575381bfabd248f1eb56f3aa21d9d7cd2511583c68c9b7511d10 2.0 MiB   linux/386,linux/amd64,linux/arm/v6,linux/arm64/v8,linux/ppc64le,linux/s390x  io.cri-containerd.image=managed
```

If you're running in KinD cluster,

```bash
docker exec <node-container> ctr -n k8s.io images ls | grep alpine
```

## Cleaning Interval

After deploying Eraser, it will automatically clean images in a regular interval. This interval can be set using the `manager.scheduling.repeatInterval` setting in the configmap.

The default interval is **24 hours (24h)**. Valid time units are **"ns", "us" (or "µs"), "ms", "s", "m", "h"**.

## Excluding registries, repositories, and images

Eraser can exclude registries (e.x., docker.io/library/*) and also specific images with a tag (e.x., docker.io/library/ubuntu:18.04) or digest (e.x., sha256:80f31da1ac7b312ba29d65080fd...) from its removal process.

To exclude any images or registries from the removal, create configmap(s) with the label eraser.sh/exclude.list=true in the eraser-system namespace with a JSON file holding the excluded images.

```bash
$ cat > sample.json <<"EOF"
{
  "excluded": [
    "docker.io/library/*",
    "ghcr.io/eraser-dev/test:latest"
  ]
}
EOF

kubectl create configmap excluded --from-file=sample.json -n eraser-system
kubectl label configmap excluded eraser.sh/exclude.list=true -n eraser-system
```

## Excluding Nodes

To prevent the Eraser from scheduling pods on certain nodes, the nodes can be given a special label. By default, this label is `eraser.sh/cleanup.filter`, but you can configure the behavior with the options under `manager.nodeFilter` [config table](https://eraser-dev.github.io/eraser/docs/customization#detailed-options).

```yaml
manager:
  nodeFilter:
    type: exclude # must be either exclude|include
    selectors:
      - eraser.sh/cleanup.filter
      - kubernetes.io/os=windows
```

## Teardown

```bash
kubectl delete -f https://raw.githubusercontent.com/eraser-dev/eraser/v1.4.1/deploy/eraser.yaml
```
