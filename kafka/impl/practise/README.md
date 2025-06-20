# Performing Kafka Operations via Docker compose

## Steps and interactions

### Deploy Kafka cluster

```bash
docker compose up -d
```

### Verify Kafka cluster

```bash
docker ps
```

### Create a topic

```bash
docker exec -it kafka-1 kafka-topics --create --topic test-topic --bootstrap-server kafka-1:9092 --partitions 1 --replication-factor 1
```

### Start producing messages on the topic

```bash
docker exec -it kafka-1 kafka-console-producer --topic test-topic --bootstrap-server kafka-1:9092
```

### Start consuming messages from the topic

```bash
docker exec -it kafka-1 kafka-console-consumer --topic test-topic --bootstrap-server kafka-1:9092 --from-beginning
```

### Stop producing/consuming messages

Press `Ctrl+C` in the terminal where you started the producer/consumer.

### List all topics

```bash
docker exec -it kafka-1 kafka-topics --list --bootstrap-server kafka-1:9092
```

### Delete the topic

```bash
docker exec -it kafka-1 kafka-topics --delete --topic test-topic --bootstrap-server kafka-1:9092
```

## Monitoring Kafka with Prometheus and Grafana

- Download the [JMX Exporter jar-0.20.0](https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.20.0/jmx_prometheus_javaagent-0.20.0.jar) and place it under `jmx-exporter/`.

- Follow directory structure for setup.

- By default, the Grafana dashboard uses the following credentials:

  Username: `admin`
  Password: `admin`

### To configure a data source in Grafana for your Kafka metrics

1. **Open Grafana:**
   Go to [http://localhost:3000](http://localhost:3000) and log in (default: `admin`/`admin`).

2. **Add Prometheus as a Data Source:**
   - In the left sidebar, click the gear icon (⚙️) for **Configuration**.
   - Click **Data sources**.
   - Click **Add data source**.
   - Select **Prometheus**.
   - In the **URL** field, enter:

     ```text
     http://prometheus:9090
     ```

     (If running Grafana outside Docker, use `http://localhost:9090`.)

   - Click **Save & Test**. You should see a success message.

3. **Import a Kafka Dashboard:**
   - Click the plus icon (+) in the sidebar, then **Import**.
   - Enter a dashboard ID from [Grafana.com dashboards](https://grafana.com/grafana/dashboards?search=kafka) (e.g., `721` or `7589`).
   - Click **Load**.
   - Select your Prometheus data source.
   - Click **Import**.

Your Kafka and Zookeeper metrics should now be visible in Grafana dashboards!

## Troubleshooting

### Common Issues

#### Error in kafka pods: Unable to start kafka with zookeeper (kafka.common.InconsistentClusterIdException)

This error indicates that the Kafka broker is trying to connect to a Zookeeper instance that has a different cluster ID than what it expects. This can happen if the Zookeeper data directory is not empty or if the Zookeeper instance was previously used with a different Kafka cluster.

To resolve this issue, you can try the following steps:

1. **Stop the Docker Compose services:**

    ```bash
    docker compose down
    ```

2. **Remove the Kafka Broker meta.properties:**

    ```bash
    rm -rf kafka-1/data/kafka-logs/meta.properties
    ```
