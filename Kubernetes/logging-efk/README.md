# Logging with EFK (ElasticSearch, FluentD, Kibana) stack

## Install Logging-Operator

- Fetch Helm chart

```bash
helm fetch oci://ghcr.io/kube-logging/helm-charts/logging-operator --untar
```

- Edit `values.yaml`.

```diff
http:
    service:
-       type: ClusterIP
-       clusterIP: None
+       type: NodePort

logging:
-   enabled: false
+   enabled: true

    fluentd:
+       bufferStorageVolume:
+           pvc:
+               spec:
+               accessModes:
+                   - ReadWriteOnce
+               storageClassName: logging
+               resources:
+                   requests:
+                   storage: 20Gi
```

- Create namespace `kube-logging`

```bash
kubectl apply -f ns-kube-logging.yml
```

- Apply `pv.yml`

- Install Helm chart.

```bash
helm install logging logging-operator -f logging-operator/values.yaml -n kube-logging
```

## Elasticsearch

- Apply Latest ElasticSearch CRDs.

```bash
kubectl create -f https://download.elastic.co/downloads/eck/2.16.1/crds.yaml
```

- Install ECK Operator.

```bash
curl https://download.elastic.co/downloads/eck/2.16.1/operator.yaml -o operator.yaml
```

- Update namespace of operator to `kube-logging` and apply.
- Apply `crd-elastic.yml`.
- Access dashboard on `HOST:30838`

- Get operator dashboard password via,

```bash
kubectl get secrets elasticsearch-es-elastic-user -o jsonpath='{.data.elastic}{"\n"}' -n kube-logging | base64 -d
```

## Kibana

- Apply `crd-kibana.yml`.

## An application for logging

- Create a POD after it.

```yaml
apiVersion: v1
kind: Pod

metadata:
    name: prod-app
    namespace: production

spec:
    containers:
        - name: prod-cont
          image: <IMAGE>
```
