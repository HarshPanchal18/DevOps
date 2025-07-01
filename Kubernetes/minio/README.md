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

### Through YAML: Apply the minio.yml file of this directory

```bash
kubectl apply -f minio.yml
```

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
