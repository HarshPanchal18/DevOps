# Grafana

* **Grafana enables you to query, visualize, alert on, and explore your metrics, logs, and traces wherever they’re stored.**

* Grafana data source plugins enable you to query data sources including time series databases like Prometheus and CloudWatch, logging tools like Loki and Elasticsearch, NoSQL/SQL databases like Postgres, CI/CD tooling like GitHub, and many more.
* Grafana OSS provides you with tools to display that data on live dashboards with insightful graphs and visualizations.

## Installation Instructions [Link](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

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
helm install my-prom prometheus-community/kube-prometheus-stack -n monitoring \
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
helm get notes my-grafana -n monitoring
```

* Yt TrainWithShubham video [Reference](https://www.youtube.com/watch?v=DXZUunEeHqM)

* Dashboard Templates for monitoring. [Link](https://grafana.com/grafana/dashboards/)

## Setting up for project

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
prometheus: # Line 3316
  prometheusSpec: # Line 3831
    scrapeInterval: "5s" # Line 3872
    evaluationInterval: "5s" # Line 3890
    additionalScrapeConfigs: # Line 4286
      - job_name: flask-app # Append this elements
        static_configs:
          - targets:
              - <Your-Project-IP>:31111
    storageSpec: # Line 4251
      volumeClaimTemplate: # Append this values
        spec:
          storageClassName: prometheus
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi

grafana: # Line 1214
  persistence: # Line 1291, append
    enabled: true
    storageClassName: "prometheus"
    accessModes:
      - ReadWriteOnce
    size: 20Gi
```

* Install Helm chart of Prometheus stack through untar-ed directory.

```bash
helm install my-prom . -f values.yaml -n monitoring \
    --set prometheus.service.nodePort=30004 --set prometheus.service.type=NodePort \
    --set grafana.service.nodePort=30006 --set grafana.service.type=NodePort \
    --set alertmanager.service.nodePort=30008 --set alertmanager.service.type=NodePort \
    --set kube-state-metrics.service.nodePort=30010 --set kube-state-metrics.service.type=NodePort \
    --set prometheus-node-exporter.service.nodePort=30012 --set prometheus-node-exporter.service.type=NodePort
```

<!-- * To add the Grafana repository, [Link](https://grafana.com/docs/grafana/latest/setup-grafana/installation/helm/)

```bash
helm repo add grafana https://grafana.github.io/helm-charts
```

* List helm repos

```bash
helm repo list
```

* update the repository to download the latest Grafana Helm charts

```bash
helm repo update
```

## Deploy the Grafana Helm charts

* Create a namespace

```bash
kubectl create ns monitoring
```

* Deploy the Grafana Helm chart

```bash
helm install my-grafana grafana/grafana --namespace monitoring
```

**_Where:_**

> * `helm install`: Installs the chart by deploying it on the Kubernetes cluster
> * `my-grafana`: The logical chart name that you provided
> * `grafana/grafana`: The repository and package name to install
> * `--namespace`: The Kubernetes namespace (i.e. monitoring) where you want to deploy the chart

* Verify the deployment status

```bash
helm list -n monitoring
kubectl get all -n monitoring
```

## Access Grafana

* Print out chart notes.

```bash
helm get notes my-grafana -n monitoring
```

* Get the Grafana admin password

```bash
kubectl get secret --namespace monitoring my-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

* Save the password to a file in system.

* Export a shell variable `POD_NAME` that will save the complete name of the pod which got deployed.

```bash
export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=my-grafana" -o jsonpath="{.items[0].metadata.name}")
```

* Direct the Grafana pod to listen to port :3000

```bash
kubectl --namespace monitoring port-forward $POD_NAME 3000
```

* Navigate to `127.0.0.1:3000` in your browser. -->
