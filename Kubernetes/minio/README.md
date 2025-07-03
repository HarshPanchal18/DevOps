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
kubectl apply -f deployment.yml -n minio-operator
kubectl apply -f console-ui.yml -n minio-operator
```

Get JWT token for the MinIO Console:

```bash
kubectl -n minio-operator get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode
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

### How do I ensure data integrity when expanding storage after pool removal

When expanding storage after pool removal, ensuring **data integrity** is critical to avoid data loss or corruption. Based on best practices from storage systems and data management, here are key guidelines to maintain data integrity during and after expansion:

#### 1. Backup and Validate Existing Data Before Expansion

- Always take a **full backup** of your data before starting pool removal or expansion.
- Verify backup integrity using **checksum or hashing algorithms** (e.g., SHA-256) to ensure data consistency.
- This protects you against accidental data loss during reconfiguration.

#### 2. Use Erasure Coding or Redundancy Features

- If your system supports **erasure coding** (like MinIO or StorageGRID), ensure it is enabled.
- Erasure coding distributes data and parity fragments across multiple drives/pools, allowing reconstruction if fragments are lost or corrupted.
- During expansion, the system can rebuild missing or corrupted fragments automatically, maintaining data integrity [3].

#### 3. Follow Operator or System-Supported Expansion Procedures

- Use your storage system’s **official expansion workflows** (e.g., MinIO Operator, StorageGRID, Windows Storage Spaces).
- These tools handle data redistribution, metadata updates, and consistency checks automatically.
- For example, MinIO Operator manages pool additions and rebalances data across new volumes without downtime.

#### 4. Monitor Data Rebalancing and Health

- After expansion, monitor the **data rebalance or migration process** closely.
- Ensure the system reports the rebalance status as “Running” then “Stopped” (completed).
- Check logs and health dashboards for errors or warnings about data corruption or incomplete migrations.

#### 5. Run Regular Data Integrity Checks

- Schedule **automated integrity checks** such as CRC or checksum verification to detect silent data corruption or bit rot.
- Some systems perform background verification and auto-healing of corrupted data fragments.
- Manual spot checks on critical data subsets can complement automated checks.

#### 6. Maintain Consistent Configuration and Avoid Mid-Expansion Changes

- Do not change critical pool parameters (like redundancy level or volumes per server) mid-expansion, as this can cause inconsistencies.
- Ensure storage nodes and drives added meet the system’s requirements for capacity and redundancy.

#### 7. Document and Log All Changes and Checks

- Keep detailed records of expansion steps, configuration changes, and integrity check results.
- This documentation helps in troubleshooting and auditing data integrity over time.

#### Summary Table

| Step                          | Description                                                                                      |
|-------------------------------|-------------------------------------------------------------------------------------------------|
| Backup and verify data         | Take backups and validate with checksums before expansion                                       |
| Use erasure coding/redundancy  | Enable and rely on erasure coding or RAID-like features for data protection                      |
| Follow official expansion tools| Use system/operator-supported expansion workflows to ensure safe data redistribution            |
| Monitor rebalance and health   | Track rebalance progress and system health to detect issues early                               |
| Run periodic integrity checks  | Schedule automated and manual data integrity verification (checksums, CRC, hashing)             |
| Avoid mid-expansion config changes | Maintain consistent pool and redundancy settings during expansion                             |
| Document changes and results   | Keep logs and records for auditing and troubleshooting                                          |

#### Additional Resources

- MinIO pool expansion and rebalancing: [MinIO Blog on Adding Pools](https://blog.min.io/add-pools-expand-capacity/)
- NetBackup MSDP data integrity checking: automated CRC and garbage cleanup
- StorageGRID erasure-coded object verification and auto-healing
- Windows Storage Spaces optimization after pool expansion
- Best practices for data integrity verification and backup

By carefully planning your expansion, backing up data, using redundancy features, and monitoring the process, you can ensure data integrity even after pool removal and storage expansion.

- [1] <https://support.microsoft.com/en-us/windows/storage-spaces-in-windows-b6c8b540-b8d8-fb8a-e7ab-4a75ba11f9f2>
- [2] <https://www.veritas.com/support/en_US/doc/25074086-151874763-0/v62562350-151874763>
- [3] <https://docs.netapp.com/us-en/storagegrid-116/monitor/verifying-object-integrity.html>
- [4] <https://forum.proxmox.com/threads/storage-checking-data-integrity-bit-rot-protection.129536/>
- [5] <https://docs.hitachivantara.com/r/en-us/virtual-storage-platform-one-sds-block/1.15.x/mk-24vsp1sds002/managing-drives/adding-drives/expanding-storage-pool>
- [6] <https://community.connection.com/backup-and-recovery-best-practices-for-data-integrity-verification/>
- [7] <https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.1800-25.pdf>
- [8] <https://www.acceldata.io/blog/how-to-ensure-data-integrity-strategies-tools-and-best-practices>

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
