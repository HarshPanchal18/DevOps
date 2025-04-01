# Spinnaker installation

- Complete steps of MinIO README.

- Create a directory for `halyard`.

```bash
mkdir -p /var/data/spinnaker/
chmod 777 /var/data/spinnaker/
```

- Create Kubernetes secret key from `spinnaker-key.json` file. Skip if already created.

```bash
kubectl create secret generic pub-sub-key --from-file=spinnaker-key.json
```

- Verify the secret key

```bash
kubectl get secrets
```

- Apply the configuration file `minio/halyard.yml`.

- Get into halyard pod.

```bash
kubectl exec -it <HALYARD_POD_NAME> -- bash
```

- Enable Kubernetes provider.

```bash
hal config provider kubernetes enable
```

- Add kubernetes account.

```bash
hal config provider kubernetes account add my-k8s-account --context $(kubectl config current-context)
```

- Set distributed deployment

```bash
hal config deploy edit --type distributed --account-name my-k8s-account
```

- Set spinnaker version

```bash
hal config version edit --version 1.37.0
```

- Configure Halyard Storage (MinIO S3)

```bash
hal config storage s3 edit \
    --endpoint http://minio-service.minio-dev.svc.cluster.local:9000 \
    --access-key-id <ACCESS-KEY> \
    --secret-access-key <SECRET-KEY> \
    --bucket spin \
    --region us-east-1 \
    --path-style-access true
```

- Set storage type to S3.

```bash
hal config storage edit --type s3
```

- Apply changes.

```bash
hal deploy apply
```

- Update the `spin-deck` and `spin-gate` services to use `NodePort` instead of `ClusterIP`, allowing external access.

```bash
kubectl get svc -n spinnaker
```

| Service Port | Target | Port | NodePort |
| ------------ | ------ | ---- | -------- |
| spin-deck    | 9000   | 9000 | 30000    |
| spin-gate    | 8084   | 8084 | 30001    |

- Set UI and API Ports

```bash
hal config security ui edit --override-base-url "http://$(ifconfig ens33 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p'):30000" # Host IP address
hal config security api edit --override-base-url "http://$(ifconfig ens33 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p'):30001" # Host IP address
```

- Apply changes to Halyard.

```bash
hal deploy apply
```

- Access dashboard on `http://<host-ip>:30000`.

- To clear out `spinnaker` deployment:

```bash
hal deploy clean
```
