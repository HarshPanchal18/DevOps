# Exporting metrics of Kafka to Prometheus in Kubernetes

## Prerequisites

- A running Kubernetes cluster.
- `kubectl` command-line tool configured to access your cluster.
- `helm` command-line tool installed.
- The Strimzi Kafka Operator installed in your cluster.
- The Prometheus Operator installed in your cluster.

## Steps to Export Kafka Metrics to Prometheus [reference](https://github.com/strimzi/strimzi-kafka-operator/blob/0.45.0/examples/metrics/prometheus-install)

1. Ensure that all pods are up and running in the `monitoring` namespace.

    ```bash
    kubectl get pods -n monitoring
    ```

2. Setup some Prometheus rules.

    ```bash
    kubectl apply -n monitoring -f prometheus-rules.yaml
    ```

3. Make sure your deployed `kafka-data` CRD looks similar to `kafka-data.yml` of current directory.

4. Create a secret through `prometheus-additional.yaml` to add additional properties to the Prometheus configuration.

    ```bash
    kubectl apply -n monitoring -f prometheus-additional.yaml
    ```

5. Deploy Pod monitors to monitor Kafka pods. This will create a `PodMonitor` resource that instructs Prometheus to scrape metrics from Kafka pods.

    ```bash
    kubectl apply -n monitoring -f pod-monitor.yaml
    ```

6. Make sure your deployed `Prometheus Server` CRD looks similar to `prometheus-crd.yml` of current directory. Verify that the `selectors` are correctly set to match your Kafka pods.

    ```bash
    kubectl get Prometheus -n monitoring
    ```

7. Verify that the Prometheus Operator and the Pod Monitor are running correctly.

    ```bash
    kubectl get pods -n monitoring
    ```

8. Check the Prometheus UI to ensure that Kafka metrics are being collected. You can access the Prometheus UI by port-forwarding:

    ```bash
    kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090
    ```

    Then, open your web browser and go to `http://localhost:9090`.

9. In the Prometheus UI, you can query Kafka metrics using the following queries:
    - To see the number of messages produced per second:

      ```text
      rate(kafka_server_brokertopicmetrics_messages_in_total[5m])
      ```

    - To see the number of messages consumed per second:

      ```text
      rate(kafka_server_brokertopicmetrics_messages_out_total[5m])
      ```

    - To monitor the request latency:

      ```text
      histogram_quantile(0.95, sum(rate(kafka_network_requestmetrics_request_latency_seconds_bucket[5m])) by (le, request))
      ```

    - To check the number of active consumers:

      ```text
      kafka_consumergroup_group_members_count
      ```

    - To monitor the number of active producers:

      ```text
      kafka_producer_topic_metrics_messages_in_total
      ```

    - To monitor the number of active topics:

      ```text
      kafka_topic_partitions
      ```

    - To monitor the number of active partitions:

      ```text
      kafka_topic_partitions{topic="your-topic-name"}
      ```

    - To monitor the number of active brokers:

      ```text
      kafka_broker_topic_metrics_messages_in_total
      ```

10. Import Grafana dashboards as needed from [Grafana Dashboards](https://github.com/strimzi/strimzi-kafka-operator/tree/0.45.0/examples/metrics/grafana-dashboards) to visualize the metrics. Visit [grafana dashboards](https://grafana.com/grafana/dashboards/?search=kafka) for more dashboards.
