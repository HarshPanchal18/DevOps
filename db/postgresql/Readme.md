# PostgreSQL in Kubernetes

## Using Helm

1. Add Helm repository

    ```bash
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    ```

2. Create PV & PVC.

    ```bash
    kubectl create -f pv.yml
    ```

3. Install Helm chart

    ```bash
    helm install psql bitnami/postgresql \
                        --set persistence.existingClaim=postgresql-pvc \
                        --set volumePermissions.enabled=true \
                        --namespace database --create-namespace
    ```

To get the password for "postgres" run:

```bash
export POSTGRES_PASSWORD=$(kubectl get secret --namespace database psql-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
```

To connect to your database run the following command:

```bash
kubectl run psql-postgresql-client --rm --tty -i --restart='Never' --namespace database --image docker.io/bitnami/postgresql:17.6.0-debian-12-r4 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
--command -- psql --host psql-postgresql -U postgres -d postgres -p 5432
```

To connect to your database from outside the cluster execute the following commands:

```bash
kubectl port-forward --namespace database svc/psql-postgresql 5432:5432 &
PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432
```

## Using operators

Install operator manifersts and resources:

```bash
curl -sSfL \
  https://raw.githubusercontent.com/cloudnative-pg/artifacts/main/manifests/operator-manifest.yaml | \
  kubectl apply --server-side -f -
```

Verify deployment

```bash
kubectl get pod -n cnpg-system
```

Deploy a postgres cluster:

```bash
kubectl apply -f pg-cluster.yml -n cnpg-system
```

Verify cluster state:

```bash
kubectl get cluster -n database -w
```

After getting cluster in `Cluster in healthy state` STATUS, check if cluster pods are created inside `database` namespace after the jobs (`initdb`, `join`) completed:

```bash
kubectl get pods -n database
```

List databases:

```bash
kubectl exec -it -n database cluster-example-1 -- psql --list
```

## Teardown

```bash
kubectl delete crd clusterimagecatalogs.postgresql.cnpg.io
kubectl delete crd clusters.postgresql.cnpg.io
kubectl delete crd databases.postgresql.cnpg.io
kubectl delete crd failoverquorums.postgresql.cnpg.io
kubectl delete crd imagecatalogs.postgresql.cnpg.io
kubectl delete crd poolers.postgresql.cnpg.io
kubectl delete crd publications.postgresql.cnpg.io
kubectl delete crd scheduledbackups.postgresql.cnpg.io
kubectl delete crd subscriptions.postgresql.cnpg.io
```

## Reference

- <https://medium.com/@simardeep.oberoi/recommended-approach-for-postgresql-in-kubernetes-83f6acc65303>
- <https://cloudnative-pg.io/documentation/1.27/architecture/>
- <https://cloudnative-pg.io/documentation/1.27/image_catalog/>
- <https://cloudnative-pg.io/documentation/1.27/cloudnative-pg.v1/#postgresql-cnpg-io-v1-ClusterSpec>
- <https://tomcam.github.io/postgres/>
