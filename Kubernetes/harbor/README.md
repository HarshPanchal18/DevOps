# Harbor Installation

* Execute `harbor-install.sh` to install Helm and fetch harbor helm charts.

* Configure `values.yaml` by applying the following values.

> Service configuration

```yaml
expose:
  type: nodePort
  tls: # TLS configuration
    enabled: false
  nodePort:
    name: harbor
    ports:
      http:
        port: 80
        nodePort: 30002
      https:
        port: 443
        nodePort: 30003
    annotations: {}
    labels: {}
```

> External URL

```yaml
# externalURL: http://harbor.harshpanchal.com:30002 # Might need an entry inside /etc/hosts
externalURL: http://NodeIp:30002
```

> PVC configuration

```yaml
persistence:
  enabled: true
  persistentVolumeClaim:
    registry:
      existingClaim: "harbor-pvc-registry"
      storageClass: "standard"
      accessMode: ReadWriteOnce
      size: 5Gi
    jobservice:
      jobLog:
        existingClaim: "harbor-pvc-jobservice"
        storageClass: "standard"
        accessMode: ReadWriteOnce
        size: 1Gi
    database:
      existingClaim: "harbor-pvc-database"
      storageClass: "standard"
      accessMode: ReadWriteOnce
      size: 1Gi
    redis:
      existingClaim: "harbor-pvc-redis"
      storageClass: "standard"
      accessMode: ReadWriteOnce
      size: 1Gi
    trivy:
      existingClaim: "harbor-pvc-trivy"
      storageClass: "standard"
      accessMode: ReadWriteOnce
      size: 5Gi
```

> Admin password

```yaml
harborAdminPassword: "Harbor12345"
```

* Create `harbor` namespace.

```bash
kubectl create ns harbor
```

* Create `volume` directory on workers.

```bash
mkdir -p /home/${USER}/volumes/{database,jobservice,redis,registry,trivy}
chmod 777 /home/${USER}/volumes/*
```

* Apply the following config file. Make sure to check the volume directory. (/home/*).

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-pv-registry
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /home/harsh/volumes/registry
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - master
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: harbor-pvc-registry
  namespace: harbor
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: standard

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-pv-jobservice
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /home/harsh/volumes/jobservice
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - master

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: harbor-pvc-jobservice
  namespace: harbor
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-pv-database
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /home/harsh/volumes/database
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - master

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: harbor-pvc-database
  namespace: harbor
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-pv-redis
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /home/harsh/volumes/redis
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - master

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: harbor-pvc-redis
  namespace: harbor
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-pv-trivy
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard

  hostPath:
    path: /home/harsh/volumes/trivy
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - master
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: harbor-pvc-trivy
  namespace: harbor
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard
```

* Install harbor through values.yaml

```bash
helm install harbor -n harbor . -f values.yaml
```

* Verify installation

```bash
kubectl get pods -n harbor
kubectl get svc -n harbor
```

* Access dashboard via `host-ip:30002` cause `externalURL` is for internal communications.

## Pushing image on harbor

* Create a new project on Harbor.

* Create a new `robot account` for login inside runner.

* Get an image.

```bash
docker pull nginx
```

* Tag it with `externalURL:port/project-name/imageName[:version]`.

```bash
docker tag nginx harbor.harsh.com:30002/inventyv/nginx-latest[:version]
```

* Push image to Harbor.

```bash
docker push harbor.harsh.com:30002/inventyv/nginx-latest[:version]
```

## Troubleshooting

* Try appending following lines inside `/etc/hosts`.

```text
HOST-IP EXTERNAL-URL
```

* **E.x.** `34.68.30.199 harbor.harsh.com`

### Error response from daemon: Get "<https://172.20.0.3:30002/v2/>": http: server gave HTTP response to HTTPS client

* Setup insecure registries inside `/etc/docker/daemon.json` and restart `docker` service.

```json
{
  "insecure-registries": ["172.20.0.3:30002"]
}
```

```bash
systemctl restart docker
```

* For ContainerD, edit `/etc/containerd/config.toml` and apply the following changes.

```toml
[plugins."io.containerd.grpc.v1.cri".registry.mirrors]
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."harbor.harsh.com:30002"]
        endpoint = ["http://harbor.harsh.com:30002"]
```

* Restart `ContainerD` service and Reload Daemon.

```bash
service containerd restart
systemctl daemon-reload
```
