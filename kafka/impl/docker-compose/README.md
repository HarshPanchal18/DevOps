# Implementation of Replication in Kafka [Ref](https://github.com/confluentinc/learn-monitoring-troubleshooting-exercises)

## Setup containers via `docker-compose`

```bash
sudo docker-compose up -d
```

* Follow steps given inside `notebooks/`.

* Check that no topics are created by default:

```bash
sudo docker compose exec -it kafka1 /opt/kafka/bin/kafka-topics.sh --bootstrap-server=kafka1:9092 --describe
```

* Create a topic `my-topic` with replication factor of 3:

```bash
sudo docker compose exec -it kafka1 /opt/kafka/bin/kafka-topics.sh --bootstrap-server=kafka1:9092 \
--create \
--topic my-topic \
--partitions 3 \
--replication-factor 3
```

* List created topic(s):

```bash
sudo docker compose exec -it kafka1 /opt/kafka/bin/kafka-topics.sh --bootstrap-server=kafka1:9092 --list
```

* Produce some messages to the topic:

```bash
sudo docker compose exec -it kafka1 /opt/kafka/bin/kafka-producer-perf-test.sh \
                              --producer-props bootstrap.servers=kafka1:9092 \
                                acks=all \
                              --topic my-topic \
                              --num-records 600000 \
                              --record-size   2048 \
                              --throughput    2000
```

## Broker Failure

* Stop one of the brokers:

```bash
sudo docker compose stop kafka2
```

* Check the status of the topic:

```bash
sudo docker compose exec -it kafka1 /opt/kafka/bin/kafka-topics.sh --bootstrap-server=kafka1:9092 --describe --topic my-topic
```

* You should see that the topic is still available, but one of the replicas is in `ISRs` (In-Sync Replicas) and the other is `OUT_OF_SYNC_REPLICAS`.

* Produce some more messages to the topic:

```bash
sudo docker compose exec -it kafka1 /opt/kafka/bin/kafka-producer-perf-test.sh \
                              --producer-props bootstrap.servers=kafka1:9092 \
                                acks=all \
                              --topic my-topic \
                              --num-records 600000 \
                              --record-size   2048 \
                              --throughput    2000
```

* Check the status of the topic again:

```bash
sudo docker compose exec -it kafka1 /opt/kafka/bin/kafka-topics.sh --bootstrap-server=kafka1:9092 --describe --topic my-topic
```

* Bring Broker2 back up:

```bash
sudo docker compose start kafka2
```

* Check the status of the topic again:

```bash
sudo docker compose exec -it kafka1 /opt/kafka/bin/kafka-topics.sh --bootstrap-server=kafka1:9092 --describe --topic my-topic
```

* You should see that the topic is now back to normal, with all replicas in `ISRs`.

* Produce some more messages to the topic:

```bash
sudo docker compose exec -it kafka1 /opt/kafka/bin/kafka-producer-perf-test.sh \
                              --producer-props bootstrap.servers=kafka1:9092 \
                                acks=all \
                              --topic my-topic \
                              --num-records 600000 \
                              --record-size   2048 \
                              --throughput    2000
```

* Check the status of the topic again:

```bash
sudo docker compose exec -it kafka1 /opt/kafka/bin/kafka-topics.sh --bootstrap-server=kafka1:9092 --describe --topic my-topic
```

* You should see that the topic is still available, with all replicas in `ISRs`.

* Check the logs of the brokers to see the replication process:

```bash
sudo docker compose logs kafka1
sudo docker compose logs kafka2
sudo docker compose logs kafka3
```

* You should see that the replication process is working, with messages being replicated from the leader to the followers.

* You can also check the status of the topic using the Kafka Console Consumer:

```bash
sudo docker compose exec -it kafka1 /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server=kafka1:9092 --topic my-topic --from-beginning
```

* This will show you the messages that have been produced to the topic, and you should see that all messages are available, even after the broker failure and recovery.
