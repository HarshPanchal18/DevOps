# MinIO - Kubernetes-native high performance object store with an S3-compatible API

It is designed to be an alternative to cloud-native storage systems.

MinIO also provides a variety of deployment options. It can run as a native application on most popular architectures and can also be deployed as a containerized application using Docker or Kubernetes.

Because of its S3 API compatibility, ability to run in a variety of deployments, and open-source nature, MinIO is a great tool for development and testing, as well as DevOps scenarios.

## How object storage works

Object storage is a data storage architecture that manages data as objects, as opposed to file systems that manage data as files and blocks. Each object typically includes the `data itself`, `metadata`, and a `unique identifier`.

The concept of object storage is similar to that of a standard Unix FS, but instead of directories and files, we use **buckets and objects**.

Buckets can be nested into a hierarchy just like directories, and objects can be thought of as just a collection of bytes. Those collections can be arbitrary byte arrays or normal files like images, PDFs, and more.

And just like directories and files, buckets and objects can have permissions. This allows fine-grained access control over data, especially in large organizations with many users.

## Architecture

![MinIO architecture](https://cdn.thenewstack.io/media/2021/11/b1e8eb64-minio-0a.png)

- Tenant: A logical grouping of **buckets and objects**. It can be thought of as a `namespace` for buckets and objects.
- Bucket: A logical container for **objects**. It can be thought of as a `directory` in a file system.
- Object: A **collection of bytes** that can be stored in a bucket. It can be thought of as a `file` in a file system.
- Metadata: Data about data. It can be thought of as the `attributes` of a file in a file system.
- Unique identifier: A unique string that uniquely `identifies` an object. It can be thought of as the `name` of a file in a file system.
- Permissions: Permissions are `access control rules` that define who can access a bucket or an object. They can be thought of as the `permissions` of a file in a file system.

## Installations

### Helm Chart

To install MinIO using Helm, you can use the following commands. This will set up the MinIO operator in a dedicated namespace called `minio-operator`.

```bash
helm repo add minio-operator https://operator.min.io
helm install --namespace minio-operator --create-namespace operator minio-operator/operator
```

Verify the installation by checking the status of the MinIO operator:

```bash
kubectl get all -n minio-operator
```

### Operator

Create a namespace for the MinIO operator:

```bash
kubectl create namespace minio-operator
```

Apply the MinIO operator CRDs:

```bash
kubectl apply -f crd/ -n minio-operator
```

Apply other resources for deployment:

```bash
kubectl apply -f sa.yml -n minio-operator
kubectl apply -f cr-crb.yml -n minio-operator
kubectl apply -f svc.yml -n minio-operator
kubectl apply -f sc-pv.yml -n minio-operator
kubectl apply -f deploy-operator.yml -n minio-operator
kubectl apply -f console-ui.yml -n minio-operator
```

Get JWT token for the MinIO Console:

```bash
kubectl -n minio-operator get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode
```

Make console service NodePort to access on browser.

```bash
kubectl patch svc -n minio-operator console --type='json' -p='[
  {"op": "replace", "path": "/spec/type", "value": "NodePort"},
  {"op": "add", "path": "/spec/ports/0/nodePort", "value": 30080}
]'
```

Get tenant management URL via viewing tenant's logs.

```bash
kubectl logs -n demo test-tenant-pool-0-0
```

Get secret for tenant user:

```bash
kubectl get secrets -oyaml -n demo test-tenant-user-0
```

and decode the access key and secret key:

```bash
echo $CONSOLE_ACCESS_KEY | base64 --decode # username
echo $CONSOLE_SECRET_KEY | base64 --decode # password
```

- To view all **tenants**, access minio operator at `http://<master-node-ip>:9090` using the access key and secret key.

- To view all **the buckets of tenant**, access tenant's `object store` at `https://<worker-node-ip>:<tenant-console-lb-port>` using the access key and secret key.

## Operations

### Expand tenant by adding a new pool

To **expand your MinIO tenant properly**, you need to add a **new pool** with the desired configuration in the tenant spec. This process is supported by the MinIO Operator and can be done non-disruptively, allowing you to increase your storage capacity seamlessly.

Here’s a step-by-step guide based on MinIO best practices and official documentation:

1. Prepare your Tenant Spec for Expansion

    - Edit your tenant manifest (YAML) to **add a new pool** under `spec.pools`.
    - Each pool defines:
    - `servers`: number of MinIO pods in the pool.
    - `volumesPerServer`: number of persistent volumes attached to each pod.
    - `volumeClaimTemplate`: storage class and size for PVCs.

    Example snippet adding a new pool:

    ```yaml
    spec:
    pools:
        - servers: 1
        volumesPerServer: 2
        volumeClaimTemplate:
            spec:
            storageClassName: standard
            resources:
                requests:
                storage: 10Gi
        - servers: 1
        volumesPerServer: 2   # New pool with required volumes per server
        volumeClaimTemplate:
            spec:
            storageClassName: standard
            resources:
                requests:
                storage: 10Gi
    ```

    - Save and exit the editor.

2. Create necessary PVs.

    - The MinIO Operator will detect the new pool and start provisioning the new pods and PVCs accordingly.

3. Verify Expansion Progress

    - Check pods and PVCs in the tenant namespace:

    ```bash
    kubectl get pods -n <tenant-namespace>
    kubectl get pvc -n <tenant-namespace>
    ```

    - Verify that new MinIO pods for the added pool are running and PVCs are bound.

    - Check tenant status:

    ```bash
    kubectl describe tenant -n <tenant-namespace>
    ```

4. Important Considerations

    - **Sufficient cluster resources:** Ensure your Kubernetes cluster has enough nodes and storage available to schedule new pods and provision PVCs.

    - **Exclusive storage access:** MinIO requires exclusive access to storage volumes (`ReadWriteOnce` PVCs). Avoid sharing volumes between pools or pods.

    - **Consistent pool configuration:** Use consistent `volumesPerServer` and storage class settings across pools for easier management.

    - **Use expansion notation in endpoints:** When specifying endpoints (if manual), use the `{x...y}` notation for volumes.

    - **Non-disruptive:** Adding new pools does not cause downtime or data loss on existing pools.

#### References and Further Reading

- Official MinIO docs on expanding tenants:
  [Expand a MinIO Tenant](https://min.io/docs/minio/kubernetes/upstream/operations/install-deploy-manage/expand-minio-tenant.html)

- MinIO blog on adding pools and expanding capacity:
  [Add Pools and expand capacity](https://blog.min.io/add-pools-expand-capacity/)

- MinIO Operator GitHub for examples and YAML templates:
  [MinIO Operator](https://github.com/minio/operator)

#### Summary

| Step                     | Action                                                                                     |
|--------------------------|--------------------------------------------------------------------------------------------|
| 1. Edit tenant spec       | Add a new pool entry with correct `servers` and `volumesPerServer`                         |
| 2. Apply config           | Run `kubectl apply -f tenant.yaml`                                                        |
| 3. Verify pods & PVCs     | Check new MinIO pods and PVCs are created and running                                     |
| 4. Ensure cluster readiness| Confirm Kubernetes cluster has enough resources and storage                               |

If you provide your current tenant YAML, I can help you draft the exact pool addition snippet for your expansion.

- [1] <https://min.io/docs/minio/kubernetes/upstream/operations/install-deploy-manage/expand-minio-tenant.html>
- [2] <https://min.io/docs/minio/kubernetes/eks/operations/install-deploy-manage/expand-minio-tenant.html>
- [3] <https://min.io/docs/minio/kubernetes/upstream/operations/install-deploy-manage/deploy-minio-tenant.html>
- [4] <https://github.com/minio/minio/issues/4364>
- [5] <https://blog.min.io/add-pools-expand-capacity/>
- [6] <https://min.io/docs/minio/kubernetes/upstream/operations/install-deploy-manage/deploy-minio-tenant-helm.html>
- [7] <https://www.adaltas.com/en/2022/07/09/s3-object-storage-minio/>
- [8] <https://github.com/minio/operator>

### Setting a MinIO alias with MinIO CLI

- Create a secret containing the MinIO access key and secret key:

```bash
kubectl create secret generic minio-creds --from-literal=CONSOLE_ACCESS_KEY=<your-access-key> --from-literal=CONSOLE_SECRET_KEY=<your-secret-key>
```

- Provide env values to the MinIO deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio-mc
spec:
  template:
    spec:
      containers:
        - name: minio-mc
          image: minio/mc:RELEASE.2025-05-21T01-59-54Z.hotfix.e98f1ead
          env:
            - name: MINIO_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: minio-creds
                  key: CONSOLE_ACCESS_KEY
            - name: MINIO_SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: minio-creds
                  key: CONSOLE_SECRET_KEY
```

- Get into the MinIO-mc pod:

```bash
kubectl exec -it <minio-mc-pod-name> -- /bin/sh
```

- Create an alias for the MinIO server using the MinIO CLI:

```bash
mc alias set myminio http://<minio-service-of-tenant-namespace>:<minio-service-port> <your-access-key> <your-secret-key>
```

### Copy a file into a MinIO bucket using MinIO CLI

- Ensure you have the MinIO CLI installed and configured with the alias set as shown above.

```bash
mc cp <local-file-path> myminio/<bucket-name>
```

- Example:

```bash
mc cp /mc-pod/path/to/local/file.txt myminio/bucket-0/
```

### Decommissioning

*[Reference](https://min.io/docs/minio/linux/operations/install-deploy-manage/decommission-server-pool.html)*

Decommissioning is designed for removing an older server pool whose hardware is no longer sufficient or performant compared to the pools in the deployment. MinIO automatically migrates data from the decommissioned pools to the remaining pools in the deployment based on the ratio of `free space available` in each pool.

During the decommissioning process, MinIO routes `read` operations (e.g. GET, LIST, HEAD) normally. MinIO routes `write` operations (e.g. PUT, versioned DELETE) to the remaining **“active”** pools in the deployment. Versioned objects maintain their ordering throughout the migration process.

> Once MinIO begins decommissioning a pool, it marks that pool as permanently inactive (“draining”). Cancelling or otherwise interrupting the decommissioning procedure does not restore the pool to an active state.

#### Back Up Cluster Settings First

Use the `mc admin cluster bucket export` and `mc admin cluster iam export` commands to take a snapshot of the `bucket metadata` and `IAM configurations` respectively prior to starting decommissioning. You can use these snapshots to restore `bucket/IAM settings` to recover from user or process errors as necessary.

1. From the console, create a new pool to where you need a transfer and make sure you had created PVs accordingly.

2. Review the status of a tenant `myminio`.

    ```bash
    mc admin decommission status myminio
    ```

    - The output can be similar to this:

    ```markdown
    ┌─────┬─────────────────────────────────────────────────────────────────────────────┬────────────────────────┬────────┐
    │ ID  │ Pools                                                                       │ Drives Usage           │ Status │
    │ 1st │ https://tenant-0-pool-0-0.tenant-0-hl.demo2.svc.cluster.local/export{0...1} │ 66.5% (total: 103 GiB) │ Active │
    │ 2nd │ https://tenant-0-pool-1-0.tenant-0-hl.demo2.svc.cluster.local/export{0...1} │ 66.5% (total: 103 GiB) │ Active │
    └─────┴─────────────────────────────────────────────────────────────────────────────┴────────────────────────┴────────┘
    ```

3. Start decommissioning by selecting pool from the table.

    ```bash
    mc admin decommission start myminio https://tenant-0-pool-0-0.tenant-0-hl.demo2.svc.cluster.local/export{0...1}
    ```

    You will get a message like below.

    ```markdown
    Decommission started successfully for `https://tenant-0-pool-0-0.tenant-0-hl.demo2.svc.cluster.local/export{0...1}`.
    ```

4. Monitor the decommissioning status.

    ```bash
    mc admin decommission status myminio
    ```

    - Specify the pool for more description.

    ```bash
    mc admin decommission status myminio https://tenant-0-pool-0-0.tenant-0-hl.demo2.svc.cluster.local/export{0...1}
    ```

    `mc admin decommission status` marks the `Status` as `Complete` once decommissioning is completed.

    ```markdown
    ┌─────┬─────────────────────────────────────────────────────────────────────────────┬────────────────────────┬──────────┐
    │ ID  │ Pools                                                                       │ Drives Usage           │ Status   │
    │ 1st │ https://tenant-0-pool-0-0.tenant-0-hl.demo2.svc.cluster.local/export{0...1} │ 66.5% (total: 103 GiB) │ Complete │
    │ 2nd │ https://tenant-0-pool-1-0.tenant-0-hl.demo2.svc.cluster.local/export{0...1} │ 66.5% (total: 103 GiB) │ Active   │
    └─────┴─────────────────────────────────────────────────────────────────────────────┴────────────────────────┴──────────┘
    ```

    If `Status` reads as `failed`, you can re-run the `mc admin decommission start` to resume the process.

    For persistent failures, use `mc admin logs` or review the `systemd` logs (e.g. `journalctl -u minio`) to identify more specific errors.

5. Remove the decommissioned pool from the configuration of tenant.

### Enable compression for new objects of bucket

```bash
mc admin config set <tenant-name> compression enable=on
```

Specify extensions for compression.

```bash
mc admin config set <tenant-name> compression extensions="*" # default: '.txt,.log,.csv,.json,.tar,.xml,.bin'
```

## EC (Erasure Coding) Calculation

### Case 1: EC3 scheme

```math
\begin{aligned}
Servers             & = 7 \\
Drive capacity      & = 2.91 \ (TiB) \\
Parity Shards       & = 3 \\
Data Shards         & = 7 - 3 = 4 \\
Drives Per Server   & = 1 \\

\\ % Blank line

Tenant Raw Capacity & = Server * Drive Capacity * Drives Per Server \\
                    & = 7 * 2.91 \\
                    & = 20.37\ TiB \\

\\ % Blank line

% Logical
Data Shard Capacity & = Tenant Capacity * (\frac{Data Shards}{Servers}) \\
                    & = 20.37 * (\frac{4}{7}) \\
                    & = 11.57\ TiB \\

\\ % Blank line

Data Storage Efficiency & = (\frac{11.57}{20.37}) * 100 \\
                        & = 57\% \\

\\ % Blank line

% Logical
Parity Shard Capacity & = Tenant Capacity * (\frac{Parity Shards}{Servers}) \\
                      & = 20.37 * (\frac{3}{7}) \\
                      & = 8.8\ TiB \\

\\ % Blank line

Current Data Usage & = 2.56\ TiB \ / \ 11.57\ TiB \\

\\ % Blank line

Raw Data  & = CurrentDataUsage * (\frac{Servers}{Data Nodes}) \\
          & = 2.56 * (\frac{7}{4}) \\
          & = 4.48\ TiB
\end{aligned}
```

### Case 2: EC2 scheme

```math
\begin{aligned}
Servers           & = 7 \\
Drive Capacity    & = 2.91 \ TiB \\
Parity Shards     & = 2 \\
Data Shards       & = 7 - 2 = 5 \\
Drives Per Server & = 1 \\

\\ % Blank line

Tenant Raw Capacity & = Server * Drive Capacity * Drives Per Server \\
                    & = 7 * 2.91 * 1 \\
                    & = 20.37\ TiB \\

\\ % Blank line

% Logical
Data Shard Capacity & = Tenant Capacity * (\frac{Data Shards}{Servers}) \\
                    & = 20.37 * (\frac{5}{7}) \\
                    & = 14.55\ TiB \\

\\ % Blank line

Data Storage Efficiency & = (\frac{14.55}{20.37}) * 100 \\
                        & = 71.42\% \\

\\ % Blank line

% Logical
Parity Shard Capacity & = Tenant Capacity * (\frac{Parity Shards}{Servers}) \\
                      & = 20.37 * (\frac{2}{7}) \\
                      & = 5.99\ TiB \\

\\ % Blank line

Current Data Usage & = 2.56\ TiB / 14.55\ TiB \\

\\ % Blank line

Raw Data  & = CurrentDataUsage * (\frac{Servers}{Data Shards}) \\
          & = 2.56 * (\frac{7}{5}) \\
          & = 3.58\ TiB
\end{aligned}
```
