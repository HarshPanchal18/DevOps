# MinIO installation

* Install Kubernetes

* Allow permissions

```bash
chmod 777 /root/.kube/config
```

* Create a directory

```bash
mkdir -p /var/data/minio
chmod 777 /var/data/minio
```

* Apply the configuration file `minio.yml`.
* Check running pods and services. Ensure that PVs and PVCs are created.
* Access MinIO dashboard on `VM-IP:30990` and login with mentioned credentials.

* Essential steps to configure MinIO:

1. Create a new MinIO bucket
2. Generate AccessKey and Secret key and keep it.
3. Change the region to `us-east-1`
