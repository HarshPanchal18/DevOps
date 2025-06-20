# Performing Kafka Operations via Docker compose

## Deploy Kafka cluster

```bash
docker compose up -d
```

## Verify Kafka cluster

```bash
docker ps
```

## Create a topic

```bash
docker exec -it kafka-1 kafka-topics --create --topic test-topic --bootstrap-server kafka-1:9092 --partitions 1 --replication-factor 1
```

## Start producing messages on the topic

```bash
docker exec -it kafka-1 kafka-console-producer --topic test-topic --bootstrap-server kafka-1:9092
```

## Start consuming messages from the topic

```bash
docker exec -it kafka-1 kafka-console-consumer --topic test-topic --bootstrap-server kafka-1:9092 --from-beginning
```

## Stop producing/consuming messages

Press `Ctrl+C` in the terminal where you started the producer/consumer.

## List all topics

```bash
docker exec -it kafka-1 kafka-topics --list --bootstrap-server kafka-1:9092
```

## Delete the topic

```bash
docker exec -it kafka-1 kafka-topics --delete --topic test-topic --bootstrap-server kafka-1:9092
```
