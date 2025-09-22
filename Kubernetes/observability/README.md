# Prometheus & Grafana

* **Grafana enables you to query, visualize, alert on, and explore your metrics, logs, and traces wherever they’re stored.**

* Grafana data source plugins enable you to query data sources including time series databases like Prometheus and CloudWatch, logging tools like Loki and Elasticsearch, NoSQL/SQL databases like Postgres, CI/CD tooling like GitHub, and many more.
* Grafana OSS provides you with tools to display that data on live dashboards with insightful graphs and visualizations.

## Installation Instructions [Reference](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

* Add Prometheus repository.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

* Create a namespace `monitoring`.

```bash
kubectl create ns monitoring
```

* Install Helm chart of Prometheus stack.

```bash
helm install prom-graf prometheus-community/kube-prometheus-stack \
    --namespace monitoring --create-namespace \
    --set prometheus.service.nodePort=30004 --set prometheus.service.type=NodePort \
    --set grafana.service.nodePort=30006 --set grafana.service.type=NodePort \
    --set alertmanager.service.nodePort=30008 --set alertmanager.service.type=NodePort \
    --set prometheus-node-exporter.service.nodePort=30010 --set prometheus-node-exporter.service.type=NodePort
```

* Verify the installation of resources.

```bash
kubectl get all -n monitoring
```

* Print out chart notes.

```bash
helm get notes prom-graf -n monitoring
```

* Yt @`TrainWithShubham` [Video](https://www.youtube.com/watch?v=DXZUunEeHqM)

* Dashboard Templates for monitoring. [Reference](https://grafana.com/grafana/dashboards/)

## Setting up for task-management project

* Add Prometheus-community repo.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

* Create namespace `monitoring`.

* Apply `storage-class.yml`, `pv-prom.yml`, and `pv-graf.yml` files.

* Create directories with permissions for volumes.

```bash
mkdir -p /home/harsh/volumes/prometheus
mkdir -p /home/harsh/volumes/grafana

chmod -R 777 /home/harsh/volumes/prometheus
chmod -R 777 /home/harsh/volumes/grafana
```

* Fetch `prometheus-stack` and untar it.

```bash
helm fetch prometheus-community/kube-prometheus-stack --untar
cd kube-prometheus-stack
```

* Update `values.yaml`

```yaml
prometheus:
  prometheusSpec:
    scrapeInterval: "5s"
    evaluationInterval: "5s"
    additionalScrapeConfigs:
      - job_name: flask-ap
        static_configs:
          - targets:
              - <Your-Project-IP>:31111
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: prometheus
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi

grafana:
  persistence:
    enabled: true
    storageClassName: "prometheus"
    accessModes:
      - ReadWriteOnce
    size: 20Gi
```

* Install Helm chart of Prometheus stack through untar-ed directory.

```bash
helm install prom-graf . -f values.yaml -n monitoring \
    --set prometheus.service.nodePort=30004 --set prometheus.service.type=NodePort \
    --set grafana.service.nodePort=30006 --set grafana.service.type=NodePort \
    --set alertmanager.service.nodePort=30008 --set alertmanager.service.type=NodePort \
    --set kube-state-metrics.service.nodePort=30010 --set kube-state-metrics.service.type=NodePort \
    --set prometheus-node-exporter.service.nodePort=30012 --set prometheus-node-exporter.service.type=NodePort
```

## Making service type to nodeport with providing nodeport

```bash
kubectl patch svc -n monitoring prom-graf-grafana --type='json' -p='[
  {"op": "replace", "path": "/spec/type", "value": "NodePort"},
  {"op": "add", "path": "/spec/ports/0/nodePort", "value": 30006}
]'
```

```bash
kubectl patch svc -n monitoring prom-graf-kube-prometheus-prometheus --type='json' -p='[
  {"op": "replace", "path": "/spec/type", "value": "NodePort"},
  {"op": "add", "path": "/spec/ports/0/nodePort", "value": 30004}
]'
```

## ServiceMonitor and PodMonitor

* **ServiceMonitor** and **PodMonitor** are custom resources provided by the Prometheus Operator to manage monitoring configurations for services and pods in Kubernetes.
* **ServiceMonitor** is used to define how Prometheus should scrape metrics from a set of services, while **PodMonitor** is used to scrape metrics directly from pods.
* These resources allow you to specify the target services or pods, the metrics path, and other scraping configurations.

### ServiceMonitor

This pseudo-CRD maps to a section of the `Prometheus custom resource configuration`. It declaratively specifies **how groups of Kubernetes services should be monitored**.

When a ServiceMonitor is created, the Prometheus Operator updates the Prometheus scrape configuration to include the ServiceMonitor configuration. Then Prometheus begins scraping metrics from the endpoint defined in the `ServiceMonitor`.

Any Services in your cluster that match the `labels` located within the `ServiceMonitor selector` field will be monitored based on the `endpoints` specified on the ServiceMonitor.

### PodMonitor

PodMonitor is similar to ServiceMonitor, but it is used to monitor individual pods rather than services. It declaratively specifies **how groups of pods should be monitored**.

When a PodMonitor is created, the Prometheus Operator updates the Prometheus scrape configuration to include the PodMonitor configuration. Prometheus then begins scraping metrics from the endpoints defined in the PodMonitor.

Any Pods in your cluster that match the labels located within the `PodMonitor selector` field will be monitored based on the `podMetricsEndpoints` specified on the PodMonitor.

## Troubleshootings

### Make alive dead service-monitors

First refer to this links:

* [Comment1](https://github.com/prometheus-operator/kube-prometheus/issues/1392#issuecomment-2082325391)
* [Comment2](https://github.com/prometheus-operator/kube-prometheus/issues/1392#issuecomment-1411719953)

If still issue persists, then follow below steps...

* `servicemonitor/monitoring/prom-graf-kube-prometheus-kube-etcd`

    Edit a `--listen-metrics-urls=http://127.0.0.1:2381` inside container arguments of `etcd` pod.

    ```bash
    sed -i 's|--listen-metrics-urls=http://127.0.0.1:2381|--listen-metrics-urls=http://0.0.0.0:2381|' /etc/kubernetes/manifests/etcd.yaml
    ```

* `servicemonitor/monitoring/prom-graf-kube-prometheus-kube-scheduler`

    ```bash
    sed -i 's|--bind-address=127.0.0.1|--bind-address=0.0.0.0|' /etc/kubernetes/manifests/kube-scheduler.yaml
    ```

* `servicemonitor/monitoring/prom-graf-kube-prometheus-kube-controller-manager`

    ```bash
    sed -i 's|--bind-address=127.0.0.1|--bind-address=0.0.0.0|' /etc/kubernetes/manifests/kube-controller-manager.yaml
    ```

* `servicemonitor/monitoring/prom-graf-kube-prometheus-kube-proxy`

    ```bash
    kubectl -n kube-system edit configmap kube-proxy
    ```

    You will see following key which is responsible for metrics.

    ```yaml
    metricsBindAddress: ""
    # OR
    metricsBindAddress: 127.0.0.1:10249
    ```

    change value to:

    ```yaml
    metricsBindAddress: 0.0.0.0:10249
    ```

  * Save and exit the editor.

  * Restart kube-proxy pods to pick up new config.

    ```bash
    kubectl -n kube-system delete pod -l k8s-app=kube-proxy
    ```

## Sharding Prometheus

![Video](https://www.youtube.com/watch?v=kEesp1tMRvM)

[Repo](https://github.com/marcel-dempers/docker-development-youtube-series/tree/master/monitoring/prometheus)

## Teardown

Uninstall Helm release.

```bash
helm uninstall -n monitoring prom-graf
```

Get remaining resources from the namespace.

```bash
kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n monitoring
```

Delete each one by one to clear out namespace.
