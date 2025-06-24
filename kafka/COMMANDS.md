# Useful commands of Kafka

## Widely Used Kafka Commands: Beginner to Advanced

Below are categorized lists of essential Kafka CLI commands, progressing from beginner to advanced usage.

---

### **Beginner Commands**

- Start Zookeeper:

  ```bash
  bin/zookeeper-server-start.sh config/zookeeper.properties
  ```

- Start Kafka broker:

  ```bash
  bin/kafka-server-start.sh config/server.properties
  ```

- Create a topic:

  ```bash
  bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic <TOPIC>  --partitions <N> --replication-factor <N>
  ```

- List all topics:

  ```bash
  bin/kafka-topics.sh --bootstrap-server localhost:9092 --list
  ```

- Describe a topic:

  ```bash
  bin/kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic <topic_name>
  ```

- Run a console producer:

  ```bash
  bin/kafka-console-producer.sh --topic <topic_name> --bootstrap-server localhost:9092
  ```

- Run a console consumer:

  ```bash
  bin/kafka-console-consumer.sh --topic <topic_name> --bootstrap-server localhost:9092
  ```

- Consume from the beginning:

  ```bash
  bin/kafka-console-consumer.sh --topic <topic_name> --bootstrap-server localhost:9092 --from-beginning
  ```

---

### **Intermediate Commands**

- Add partitions to a topic:

  ```bash
  bin/kafka-topics.sh --bootstrap-server localhost:9092 --alter --topic <topic_name> --partitions <N>
  ```

- Delete a topic:

  ```bash
  bin/kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic <topic_name>
  ```

- List consumer groups:

  ```bash
  bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
  ```

- Describe a consumer group:

  ```bash
  bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group <group_id>
  ```

- Delete a consumer group:

  ```bash
  bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --delete --group <group_id>
  ```

---

### **Advanced Commands**

- Reset offsets for a consumer group:

  ```bash
  bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --reset-offsets --group <group_id> --topic <topic_name> --to-earliest
  ```

- Purge a topic (change retention period temporarily):

  ```bash
  bin/kafka-topics.sh --bootstrap-server localhost:9092 --alter --topic <topic_name> --config retention.ms=1000
  ```

- Remove retention override:

  ```bash
  bin/kafka-topics.sh --bootstrap-server localhost:9092 --alter --topic <topic_name> --delete-config retention.ms
  ```

- Get the number of messages in a topic:

  ```bash
  bin/kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list <BROKER_LIST> --topic <topic_name> --time -1 --offsets 1 | awk -F ":" '{sum += $3} END {print sum}'
  ```

- Get earliest/latest offsets:

  ```bash
  bin/kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list <BROKER_LIST> --topic <topic_name> --time -2   # earliest
  bin/kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list <BROKER_LIST> --topic <topic_name> --time -1   # latest
  ```

---

- [1] <https://www.redpanda.com/guides/kafka-tutorial-kafka-cheat-sheet>
- [2] <https://gist.github.com/sonhmai/5b2b4455162c808c091b661aeb675625>
- [3] <https://docs.confluent.io/kafka/operations-tools/kafka-tools.html>
- [4] <https://kafka.apache.org/quickstart>
- [5] <https://hevodata.com/learn/kafka-cli-commands/>
- [6] <https://learn.conduktor.io/kafka/kafka-topics-cli-tutorial/>
- [7] <https://support.k2view.com/Academy/articles/02_fabric_architecture/08_kafka_basic_commands.html>
- [8] <https://kafka.apache.org/documentation/>
