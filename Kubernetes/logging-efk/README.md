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
kubectl create -f https://download.elastic.co/downloads/eck/2.16.1/crds.yaml -n kube-logging
```

- Download ECK Operator.

```bash
curl https://download.elastic.co/downloads/eck/2.16.1/operator.yaml -o operator.yaml
```

- Update namespace of operator to `kube-logging` and apply.

```bash
sed -i 's/namespace: logging/namespace: kube-logging/' operator.yaml
kubectl apply -f operator.yaml
```

- Apply `crd-elastic.yml`.

## Kibana

- Apply `crd-kibana.yml`.
- Get port of `kibana-kb-http` nodeport service
- Access dashboard on `HOST:PORT`
- Get operator dashboard password via,

```bash
kubectl get secrets elasticsearch-es-elastic-user -o jsonpath='{.data.elastic}{"\n"}' -n kube-logging | base64 -d
```

## An application for logging

- Create a POD after it.

```yaml
apiVersion: v1
kind: Pod

metadata:
    name: production
    labels:
      app: production
    namespace: production

spec:
    containers:
        - name: production
          image: chentex/random-logger:latest
```

OR

```bash
kubectl apply -f deploy-logger.yml
```

## Apply ClusterFlow and ClusterOutput

```bash
kubectl apply -f cflow-coutput.yml
```

- Make sure to update password provided inside above YAML.

## Apply Metric Beat for visualization

```bash
kubectl apply -f metric-beat.yml
```

## Theories

### Flow, ClusterFlow, Output, and ClusterOutput

The terms Flow, ClusterFlow, Output, and ClusterOutput are related to `Fluent Bit` or `Fluentd` configurations. These components are used to define how logs are _collected, processed, and routed_ to their destinations.

1. Flow

    - A Flow is a namespace-scoped configuration in Fluent Bit or Fluentd that defines **how logs are filtered and routed** within a specific Kubernetes namespace.
    - It specifies the match conditions (e.g., labels, namespaces) and the Output to which the logs should be sent.
    - Typically used when you want to _route logs from specific pods or namespaces to a particular destination._

    **Example:**

    ```yaml
    apiVersion: logging.k8s.io/v1alpha1
    kind: Flow
    metadata:
        name: app-logs-flow
        namespace: app-namespace
    spec:
        match:
            labels:
                app: my-app
        filters:
            - name: parser
            parameters:
                format: json
        outputRefs:
            - elasticsearch-output
    ```

    - `match`: Defines which logs to process (e.g., logs from pods with specific labels).
    - `outputRefs`: References the Output configuration where logs will be sent.

2. ClusterFlow

    - A ClusterFlow is similar to a Flow but operates at the cluster level (not restricted to a single namespace).
    - It is used to define global log routing rules that apply to logs from all namespaces or specific namespaces across the cluster.
    - Useful for _centralizing log management_ for the entire cluster.

    **Example:**

    ```yaml
    apiVersion: logging.k8s.io/v1alpha1
    kind: ClusterFlow
    metadata:
        name: cluster-logs-flow
    spec:
        match:
            namespaces:
            - kube-system
            - default
        filters:
            - name: grep
            parameters:
                regex: "ERROR"
        outputRefs:
            - elasticsearch-output
    ```

    - `match`: Specifies namespaces or other criteria for selecting logs.
    - `outputRefs`: References the ClusterOutput configuration.

3. Output

    - An Output is a namespace-scoped configuration that defines _the destination where logs should be sent_ (e.g., Elasticsearch, S3, or another logging system).
    - It is used in conjunction with a Flow to route logs from a specific namespace to a destination.

    **Example:**

    ```yaml
    apiVersion: logging.k8s.io/v1alpha1
    kind: Output
    metadata:
        name: elasticsearch-output
        namespace: app-namespace
    spec:
        type: elasticsearch
        parameters:
            host: "http://elasticsearch:9200"
            index: "app-logs"
    ```

    `type`: Specifies the type of destination (e.g., elasticsearch, s3, etc.).
    `parameters`: Contains the configuration details for the destination.

4. ClusterOutput

    - A ClusterOutput is similar to an Output but operates at the cluster level.
    - It defines _a global destination for logs, which can be referenced by ClusterFlow or Flow configurations._
    - Useful for sending logs from multiple namespaces or the entire cluster to a centralized logging system.

    **Example:**

    ```yaml
    apiVersion: logging.k8s.io/v1alpha1
    kind: ClusterOutput
    metadata:
        name: elasticsearch-cluster-output
    spec:
        type: elasticsearch
    parameters:
        host: "http://elasticsearch:9200"
        index: "cluster-logs"
    ```

    `type`: Specifies the destination type.
    `parameters`: Contains the configuration details for the destination.

- Summary of Relationships:
  - `Flow`: Namespace-scoped log routing rules.
  - `ClusterFlow`: Cluster-wide log routing rules.
  - `Output`: Namespace-scoped log destination configuration.
  - `ClusterOutput`: Cluster-wide log destination configuration.

- Example Workflow:
    1. `ClusterFlow` matches logs from specific namespaces or pods across the cluster.
    2. `Logs` are routed to a ClusterOutput, which sends them to Elasticsearch.
    3. Alternatively, a Flow can match logs within a specific namespace and route them to an Output.

This modular approach allows fine-grained control over log collection and routing in Kubernetes.
