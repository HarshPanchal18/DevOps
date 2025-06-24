# How To and setups particularly in Kafka

## Index

- [How to set up Kafka with Docker](#how-to-set-up-kafka-with-docker)
- [How to set up Kafka with Docker Compose](#how-to-set-up-kafka-with-docker-compose)
- [How to create a schema registry in Kafka?](#how-to-create-a-schema-registry-in-kafka)
- [How to use Avro serialization with Kafka?](#how-to-use-avro-serialization-with-kafka)
- [How to achieve Message Delivery Semantics in Kafka?](#how-to-achieve-message-delivery-semantics-in-kafka)
- [How to Find Out Who Subscribed to Topics in Kafka?](#how-to-find-out-who-subscribed-to-topics-in-kafka)
- [How to Expand a Kafka Cluster?](#how-to-expand-a-kafka-cluster)
- [How MirrorMaker2 Connectors Handle Topic Filtering and Renaming](#how-mirrormaker-2-connectors-handle-topic-filtering-and-renaming)
- [How are internal topics used to manage and track filtered or renamed topics](#how-are-internal-topics-used-to-manage-and-track-filtered-or-renamed-topics)

## How to set up Kafka with Docker

```bash
docker run -d --name zookeeper -p 2181:2181 wurstmeister/zookeeper:3.4.6
docker run -d --name kafka -p 9092:9092 --link zookeeper:zookeeper wurstmeister/kafka:latest
```

## How to set up Kafka with Docker Compose

```yaml
version: '2'
services:
  zookeeper:
    image: wurstmeister/zookeeper:3.4.6
    ports:
      - "2181:2181"
  kafka:
    image: wurstmeister/kafka:latest
    ports:
      - "9092:9092"
    expose:
      - "9093"
    environment:
      KAFKA_ADVERTISED_LISTENERS: INSIDE://kafka:9093,OUTSIDE://localhost:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT
      KAFKA_LISTENERS: INSIDE://0.0.0.0:9093,OUTSIDE://0.0.0.0:9092
    depends_on:
      - zookeeper
    links:
      - zookeeper:zookeeper
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    ports:
      - "8080:8080"
    environment:
      KAFKA_CLUSTERS_0_NAME: "Local Kafka"
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: "kafka:9093"
      KAFKA_CLUSTERS_0_ZOOKEEPER: "zookeeper:2181"
    depends_on:
      - kafka
      - zookeeper

networks:
  default:
    driver: bridge
```

## How to create a schema registry in Kafka?

### Overview

A Kafka Schema Registry is a centralized service for managing and validating schemas used in Kafka messages. It ensures producers and consumers agree on data structure, supports schema evolution, and helps prevent serialization and deserialization errors.

![Schema Registry](https://miro.medium.com/v2/resize:fit:1358/1*LSf9VtT7qd8JVsu8QmpV1g.png "Schema Registry")

### Steps to Create and Use a Schema Registry in Kafka

1. **Deploy the Schema Registry Service**

    - If using Confluent Platform, start the Schema Registry service (often via Docker or as a standalone service).
    - Example (Docker Compose for Confluent Schema Registry):

    ```yaml
    schema-registry:
      image: confluentinc/cp-schema-registry:latest
      depends_on:
        - kafka
      environment:
        SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS: 'PLAINTEXT://kafka:9092'
        SCHEMA_REGISTRY_LISTENERS: 'http://0.0.0.0:8081'
      ports:
        - "8081:8081"
    ```

2. **Register a Schema**

    - Use the Schema Registry REST API to register a new schema.
    - Example (registering an Avro schema for the subject `order-value`):

    ```bash
    curl -X POST http://localhost:8081/subjects/order-value/versions \
      -H "Content-Type: application/vnd.schemaregistry.v1+json" \
      -d '{
            "schema": "{\"type\":\"record\",\"name\":\"order\",\"fields\":[{\"name\":\"order_id\",\"type\":\"int\"},{\"name\":\"item_name\",\"type\":\"string\"}]}"
          }'
    ```

3. **Configure Producer and Consumer**

    - Configure your Kafka producers and consumers to use the Schema Registry URL (e.g., `http://localhost:8081`).
    - Use the Avro serializer/deserializer libraries that integrate with the Schema Registry.

4. **(Optional) Use Schema Registry UI**

    - Some platforms (e.g., Cloudera) provide a UI for managing schemas:
      - Access the UI (e.g., `http://localhost:7788/`).
      - Add a new schema, set its name, type (Avro/JSON), group, and compatibility policy [FORWARD, BACKWARD, BOTH, NONE].

### Best Practices

- Use Avro as the serialization format for most use cases.
- Set compatibility policies to manage schema evolution [e.g., BACKWARD for safe changes].
- Do not rename or delete required fields; use aliases or default values instead.

The Schema Registry enables robust data contracts and safe schema evolution in distributed Kafka environments.

- [1] <https://docs.confluent.io/platform/current/schema-registry/develop/using.html>
- [2] <https://www.redpanda.com/guides/kafka-tutorial-kafka-schema-registry>
- [3] <https://docs.confluent.io/platform/current/schema-registry/index.html>
- [4] <https://www.youtube.com/watch?v=5fjw62LGYNg>
- [5] <https://docs.cloudera.com/csp-ce/latest/getting-started/topics/csp-ce-sm-sr.html>
- [6] <https://www.instaclustr.com/support/documentation/kafka-add-ons/using-the-kafka-schema-registry/>
- [7] <https://www.digitalocean.com/community/tutorials/how-to-set-up-confluent-schema-registry-in-kafka>
- [8] <https://www.codingshuttle.com/spring-boot-handbook/kafka-schema-registry-with-confluent>

## How to use Avro serialization with Kafka?

To use Avro serialization with Kafka, integrate the Confluent Schema Registry and configure producers/consumers to handle Avro schemas. Here's a structured implementation guide:

---

### **Implementation Steps**

1. **Add Dependencies**

    ```xml
    <dependency>
        <groupId>io.confluent</groupId>
        <artifactId>kafka-avro-serializer</artifactId>
        <version>7.6.0</version>
    </dependency>
    ```

2. **Configure Producer**

    ```java
    Properties props = new Properties();
    props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
    props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
    props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, KafkaAvroSerializer.class);
    props.put("schema.registry.url", "http://localhost:8081"); // Schema Registry URL

    KafkaProducer producer = new KafkaProducer<>(props);
    ```

3. **Define Avro Schema**

    ```json
    {
      "type": "record",
      "name": "User",
      "fields": [
        {"name": "id", "type": "int"},
        {"name": "name", "type": "string"}
      ]
    }
    ```

4. **Create and Send Avro Record**

    ```java
    Schema.Parser parser = new Schema.Parser();
    Schema schema = parser.parse(userSchema); // userSchema is the JSON string above

    GenericRecord avroRecord = new GenericData.Record(schema);
    avroRecord.put("id", 101);
    avroRecord.put("name", "Alice");

    ProducerRecord record =
        new ProducerRecord<>("users-topic", "user-key", avroRecord);
    producer.send(record);
    ```

5. **Configure Consumer**

    ```java
    Properties props = new Properties();
    props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
    props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
    props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, KafkaAvroDeserializer.class);
    props.put("schema.registry.url", "http://localhost:8081");

    KafkaConsumer consumer = new KafkaConsumer<>(props);
    consumer.subscribe(Collections.singletonList("users-topic"));
    ```

---

### **Key Features**

| Feature               | Description                                                                 |
|-----------------------|-----------------------------------------------------------------------------|
| Schema Registry       | Centralized schema storage; ensures compatibility checks.                   |
| Schema Evolution      | Supports backward/forward compatibility [e.g., adding/removing fields].     |
| Reduced Bandwidth     | Sends schema ID instead of full schema with each message.                   |

---

### **Best Practices**

- **Use SpecificRecord for Type Safety**: Generate Java classes from Avro schemas (via Maven/Gradle plugins) instead of `GenericRecord`.
- **Set Compatibility Mode**: Configure `BACKWARD` or `FULL` compatibility in Schema Registry to safely evolve schemas.
- **Cache Schemas Locally**: Reduce Schema Registry lookups by enabling client-side schema caching.

---

### **Troubleshooting**

- **`SerializationException`**: Ensure schemas are registered and compatible.
- **Consumer Errors**: Verify the consumer has network access to the Schema Registry.

Avro serialization ensures efficient data contracts and schema evolution in Kafka, reducing errors in distributed systems.

- [1] <https://docs.confluent.io/platform/current/schema-registry/fundamentals/serdes-develop/serdes-avro.html>
- [2] <https://dzone.com/articles/kafka-avro-serialization-and-the-schema-registry>
- [3] <https://www.youtube.com/watch?v=_6HTHH1NCK0>
- [4] <https://codingharbour.com/apache-kafka/guide-to-apache-avro-and-kafka/>
- [5] <https://pekko.apache.org/docs/pekko-connectors-kafka/current/serialization.html>
- [6] <https://quarkus.io/guides/kafka-schema-registry-avro>
- [7] <https://www.confluent.io/ko-kr/blog/schema-registry-avro-in-spring-boot-application-tutorial/>
- [8] <https://www.cesarsotovalero.net/blog/data-serialization-deserialization-in-java-with-apache-avro.html>

## How to achieve Message Delivery Semantics in Kafka?

Kafka provides three message delivery semantics that determine `how messages are handled between producers, brokers, and consumers`. These guarantees balance tradeoffs between `reliability`, `performance`, and `complexity`.

![Kafka message delivery semantics](https://www.widgetbox.com/wp-content/uploads/2022/03/word-image-15.jpeg "Kafka Message Delivery Semantics")

---

### **At-Most-Once Delivery**

- **Guarantee**: Messages are delivered once or not at all. Potential message loss during failures.

- **Producer Configuration**:
  - `acks=0` (no broker acknowledgment)
  - `retries=0` (no retries on failure)

- **Consumer Configuration**:
  - `enable.auto.commit=true` (offsets committed before processing)

- **Use Case**: Low-latency applications where occasional data loss is acceptable (e.g., metrics collection).

---

### **At-Least-Once Delivery**

- **Guarantee**: Messages are never lost but may be duplicated.

- **Producer Configuration**:
  - `acks=all` (wait for all replicas to acknowledge)
  - `retries=Integer.MAX_VALUE` (retry indefinitely)

- **Consumer Configuration**:
  - `enable.auto.commit=false` (manual offset commits after processing)

- **Risk**: Duplicates occur if a producer retries after a network error or a consumer crashes mid-processing.

---

### **Exactly-Once Delivery**

- **Guarantee**: Messages are processed once and only once, even during failures.

- **Required Configurations**:

  - **Idempotent Producer**:

    ```properties
    enable.idempotence=true
    max.in.flight.requests.per.connection=5
    ```

    Configure producers to prevent duplicates during retries via unique producer IDs and sequence numbers:

    ```java
    props.put("enable.idempotence", "true");
    props.put("acks", "all"); // Ensure all replicas acknowledge writes
    props.put("max.in.flight.requests.per.connection", "5"); // Optimize throughput
    ```

- **Idempotence** ensures that retried messages do not result in duplicates by assigning a unique `producer ID` and `sequence number` to each message.

  - **Transactions** ensure that messages and consumer offsets are **committed together**, preventing duplicates or data loss during failures.

    ```java
    // Producer configuration
    props.put("transactional.id", "unique-transaction-id");

    // Initialize transactions
    KafkaProducer producer = new KafkaProducer<>(props);
    producer.initTransactions();

    // Transactional write
    producer.beginTransaction();
    producer.send(record);
    producer.sendOffsetsToTransaction(offsets, consumerGroupMetadata);
    producer.commitTransaction();
    ```

    Atomically commits messages and consumer offsets.

- **Consumer Isolation**:

    ```properties
    isolation.level=read_committed
    ```

    Ignores uncommitted transactional messages.

  - Set consumers to read only committed messages:

    ```java
    props.put("isolation.level", "read_committed");
    ```

  - This ensures consumers ignore messages from aborted transactions.

- **Use Case**: Financial transactions or systems requiring strict data integrity.

---

### Comparison Table

| **Semantic**        | **Delivery Guarantee**       | **Producer Config**                     | **Consumer Config**               | **Performance** |
|---------------------|------------------------------|-----------------------------------------|-----------------------------------|-----------------|
| At-Most-Once        | Possible message loss        | `acks=0`, `retries=0`                   | Auto-commit before processing     | Lowest latency  |
| At-Least-Once       | No loss, possible duplicates | `acks=all`, `retries=MAX`               | Manual commit after processing    | Moderate        |
| Exactly-Once        | No loss or duplicates        | `enable.idempotence=true`, transactions | `isolation.level=read_committed`  | Highest overhead|

---

### Key Challenges

1. **Distributed Systems Complexity**: Network partitions and broker failures require careful handling of retries and offsets.
2. **External Systems**: Exactly-once semantics only apply within Kafka. Integrations with databases or APIs require idempotent application logic.
3. **Performance Tradeoffs**:
   - At-least-once adds latency due to retries and acknowledgments.
   - Exactly-once incurs ~3-20% overhead from transactional coordination.
4. **Kafka Connect Limitations**: Exactly-once for source connectors is not fully supported in all scenarios.

**In practice**: Use at-least-once for most scenarios, and enable exactly-once for critical data pipelines. For Kafka Streams, set `processing.guarantee=exactly_once` to handle stateful operations atomically.

By combining `idempotent producers`, `transactional commits`, and proper `consumer isolation`, Kafka guarantees exactly-once semantics within its ecosystem. For end-to-end guarantees, ensure application logic and external systems align with these protocols.

- [1] <https://docs.confluent.io/kafka/design/delivery-semantics.html>
- [2] <https://www.confluent.io/blog/exactly-once-semantics-are-possible-heres-how-apache-kafka-does-it/>
- [3] <https://www.baeldung.com/kafka-exactly-once>
- [4] <https://spring.io/blog/2023/10/16/apache-kafkas-exactly-once-semantics-in-spring-cloud-stream-kafka>
- [5] <https://hevodata.com/blog/kafka-exactly-once-semantics/>
- [6] <https://www.reddit.com/r/apachekafka/comments/q1wrzl/how_is_exactly_once_in_kafka_an_achievement/>
- [7] <https://www.youtube.com/watch?v=Ki2D2o9aVl8>
- [8] <https://stackoverflow.com/questions/44362563/kafka-how-to-implement-exactly-once-message-delivery-logic-with-topic-partition>
- [9] <https://www.esolutions.tech/delivery-guarantees-provided-by-Kafka>
- [10] <https://life.wongnai.com/deep-dive-into-message-delivery-guarantees-in-kafka-part-1-0f09072e5962>
- [11] <https://gist.github.com/pavelfomin/b53eb89a03f5d515e440f7c45a601080>
- [12] <https://jack-vanlightly.com/blog/2017/12/15/rabbitmq-vs-kafka-part-4-message-delivery-semantics-and-guarantees>
- [13] <https://life.wongnai.com/deep-dive-into-message-delivery-guarantees-in-kafka-part-2-04c770e62abb>
- [14] <https://dev.to/paulocappa/delivery-guarantees-with-kafka-balancing-resilience-and-performance-3dh9>

---

## How to Find Out Who Subscribed to Topics in Kafka?

**Kafka does not directly track or expose a list of all consumers currently subscribed to a topic.** However, you can determine which consumer groups are actively consuming from a topic using built-in Kafka tools.

### Using the Kafka Consumer Groups Tool

Kafka provides the `kafka-consumer-groups.sh` command-line tool, which allows you to list consumer groups and see their topic subscriptions. Here’s how you can use it:

- To list all consumer groups:

  ```bash
  kafka-consumer-groups.sh --bootstrap-server <broker>  --list
  ```

- To see which consumer groups are subscribed to a specific topic:

  ```bash
  kafka-consumer-groups.sh --bootstrap-server <broker>  --describe --group <group_id>
  ```

- To see all consumer groups and their topic subscriptions:

  ```bash
  kafka-consumer-groups.sh --bootstrap-server <broker>  --describe --all-groups
  ```

- To list all consumer groups and their offsets for a specific topic:

  ```bash
  kafka-consumer-groups.sh --bootstrap-server <broker>  --describe --all-groups --topic <topic_name>
  ```

- To describe a specific consumer group and see which topics and partitions it is consuming:

  ```bash
  kafka-consumer-groups.sh --bootstrap-server <broker>  --describe --group <group_id>
  ```

This will show you:

- The consumer `group ID`.
- The `topics and partitions` the group is consuming.
- The `current offset` and `lag` for each partition.

### Key Points

- **Consumer Groups**: Kafka organizes consumers into consumer groups. Each group can subscribe to one or more topics, and Kafka will distribute partitions of those topics among the consumers in the group.
- **No Direct List of Individual Consumers**: Kafka does not maintain a direct registry of all individual consumers for a topic. It tracks consumer groups and their partition assignments.
- **Non-Group Consumers**: If a consumer is not part of a consumer group (rare in production), it is not tracked by Kafka’s offset management, making it difficult to discover via standard tools.
- **Network Traffic Analysis (Advanced)**: In extreme cases, you could analyze network traffic between brokers and clients to infer which consumers are fetching from which topics, but this is complex and rarely necessary.

### Summary Table

| What You Can See           | How to See It                                    | Tool/Method                  |
|----------------------------|--------------------------------------------------|------------------------------|
| Consumer groups per topic  | List and describe consumer groups                | kafka-consumer-groups.sh     |
| Individual consumers in CG | See members of a consumer group                  | kafka-consumer-groups.sh     |
| Non-group consumers        | Not directly visible (requires network analysis) | Advanced network monitoring  |

### Additional Notes

- The `kafka-topics.sh` tool is for topic management (create, delete, describe) and does not show consumer information.
- For managed Kafka (e.g., Confluent, Strimzi), similar CLI or UI tools are available.
- In Kubernetes environments like Strimzi, you can run these commands from a pod with Kafka client tools installed.

**In summary:** Use `kafka-consumer-groups.sh` to find out which consumer groups are subscribed to a topic. Kafka does not provide a direct list of all individual consumers, but you can see the group-level assignments and partition consumption details.

- [1] <https://stackoverflow.com/questions/53090441/check-subscribers-of-a-kafka-topic>
- [2] <https://kafka.apache.org/intro>
- [3] <https://codemia.io/knowledge-hub/path/apache_kafka_how_to_find_out_consumer_group_of_a_topic>
- [4] <https://learn.conduktor.io/kafka/kafka-topics-cli-tutorial/>
- [5] <https://www.redpanda.com/guides/kafka-architecture-kafka-topics>
- [6] <https://www.instaclustr.com/education/apache-kafka/apache-kafka-architecture-a-complete-guide-2025/>
- [7] <https://www.youtube.com/watch?v=QkdkLdMBuL0>
- [8] <https://docs.confluent.io/kafka/operations-tools/kafka-tools.html>

## How to Expand a Kafka Cluster?

A Kafka cluster consists of multiple brokers, and it is through adding more brokers that scalability is achieved. Topics, where messages are stored, are divided into partitions, which can be spread across multiple brokers for load balancing and redundancy.

### Prerequisites

- Existing Kafka cluster running with at least one broker
- Zookeeper ensemble managing the Kafka brokers
- Basic understanding of Kafka architecture and concepts
- Access to Kafka and Zookeeper configuration files
- Proper backup of Kafka data and configurations

1. Install a new Kafka broker on the new machine:

    - Download and extract the Kafka binaries.

      ```bash
      wget https://dlcdn.apache.org/kafka/3.9.0/kafka_2.13-3.9.0.tgz
      tar -xzf kafka_2.13-3.9.0.tgz
      ```

    - Ensure Java is installed on the new machine.

2. Configure the new broker:

    - Configure the `server.properties` file for the new broker:
      - Set a unique `broker.id`.
      - Configure `listeners` and `advertised.listeners` to match your network setup.
      - Set the `log.dirs` to a directory where Kafka can store its data.

    ```properties
    # Set unique broker ID and Zookeeper connect string
    broker.id=3
    zookeeper.connect=zoo1:2181,zoo2:2181,zoo3:2181

    # Configuring rack awareness
    broker.rack=RackA
    default.replication.factor=3
    ```

3. Start the new broker:

    - Start the Kafka server with the new configuration.

      ```bash
      bin/kafka-server-start.sh config/server.properties
      ```

4. Reconfigure topics for load balancing.

    - Use the `kafka-topics.sh` tool to reassign partitions across the cluster.
    - Create a reassignment JSON file specifying the new partition distribution.

      ```json
      {
        "version": 1,
        "partitions": [
          {"topic": "my-topic", "partition": 0, "replicas": [1, 2, 3]},
          {"topic": "my-topic", "partition": 1, "replicas": [2, 3, 4]}
        ]
      }
      ```

    - Execute the reassignment command:

      ```bash
      bin/kafka-reassign-partitions.sh --zookeeper zoo1:2181,zoo2:2181,zoo3:2181 --reassignment-json-file reassignment.json --execute
      ```

5. Verify the new broker and partition distribution:

    - Use the `kafka-topics.sh` tool to describe the topic and check partition assignments.

      ```bash
      bin/kafka-topics.sh --zookeeper zoo1:2181,zoo2:2181,zoo3:2181 --describe --topic my-topic
      ```

6. Monitor the cluster:

    - Use Kafka monitoring tools (e.g., Confluent Control Center, Prometheus, Grafana) to ensure the new broker is functioning correctly and partitions are balanced.

7. Update client configurations:

    - If clients are using static broker lists, update them to include the new broker's address.
    - Ensure that clients can connect to the new broker and consume/produce messages as expected.

## How MirrorMaker 2 Connectors Handle Topic Filtering and Renaming

MirrorMaker 2 (MM2) provides robust mechanisms for topic filtering and renaming to manage and control cross-cluster replication.

### **Topic Filtering**

- **Filtering by Topic Name:**
  MM2 allows you to specify which topics to replicate using **regular expressions** or **allow-lists** in the connector configuration. This means you can include or exclude topics based on **naming patterns**, ensuring only the desired topics are mirrored to the target cluster.

- **Cycle Prevention Filtering:**
  MM2 has built-in logic to **prevent replication loops**. It filters out topics that already contain the target cluster's name as a prefix, which indicates the topic originated from that cluster. For example, if a topic named `A.topic1` exists on cluster B, MM2 will not replicate it back to cluster A, preventing infinite replication cycles.

  A replication loop incident can happen in MirrorMaker 2 (MM2) when you have **bidirectional replication** set up between two Kafka clusters (for example, Cluster A and Cluster B), and there is no filtering or renaming to distinguish the origin of topics.

### **Topic Renaming**

- **Automatic Renaming (Default Behavior):**
  By default, MM2 renames replicated topics in the target cluster by prefixing them with the **source cluster’s alias** (e.g., replicating `topic1` from cluster A to cluster B results in `A.topic1` on cluster B).

  This naming convention:
  - Clearly distinguishes between local and remote (replicated) topics.
  - Supports active-active replication by keeping local and remote records separate.
  - Prevents accidental merging of data from different clusters and supports cycle prevention.

- **Disabling Renaming:**
  If renaming is disabled, MM2 replicates topics without changing their names (e.g., `topic1` on cluster A becomes `topic1` on cluster B). However, this can create the risk of infinite replication loops in bidirectional setups, as MM2 cannot distinguish between locally produced and remotely replicated messages.

### **Summary Table: MM2 Topic Filtering and Renaming**

| Feature                  | Description                                                                                    | Default Behavior      |
|--------------------------|------------------------------------------------------------------------------------------------|-----------------------|
| Topic Filtering          | Select topics to replicate using regular expressions or allow-lists                            | Configurable          |
| Cycle Prevention         | Filters out topics with target cluster prefix to avoid loops                                   | Enabled               |
| Topic Renaming           | Prefixes replicated topics with source cluster alias (e.g., `A.topic1`)                        | Enabled               |
| Renaming Disabled        | Replicates topics with the same name in both clusters (risk of loops in bidirectional setups)  | Optional              |

### **Key Points**

- MM2’s filtering and renaming policies are essential for safe, scalable, and manageable multi-cluster Kafka deployments.
- These features are configured in the connector’s configuration file, allowing fine-grained control over which topics are replicated and how they are named in the target cluster.

**In summary:**
MirrorMaker 2 connectors use configurable topic filters and a default renaming policy to control which topics are replicated and to prevent replication cycles, ensuring reliable and organized cross-cluster Kafka replication.

- [1] <https://www.instaclustr.com/blog/apache-kafka-mirrormaker-2-practice/>
- [2] <https://developers.redhat.com/articles/2023/11/13/demystifying-kafka-mirrormaker-2-use-cases-and-architecture>
- [3] <https://community.zenduty.com/t/mirror-maker-filtering-messages-on-topic-based-on-key-value-in-headers/580>
- [4] <https://github.com/AutoMQ/automq/wiki/Kafka-MirrorMaker-2(MM2):-Usages-&-Best-Practices>
- [5] <https://www.instaclustr.com/blog/kafka-mirrormaker-2-theory/>
- [6] <https://cwiki.apache.org/confluence/display/KAFKA/KIP-382:+MirrorMaker+2.0>
- [7] <https://stackoverflow.com/questions/75080963/is-it-possible-to-filter-some-data-from-topic-instead-of-moving-its-data-content>
- [8] <https://docs.cloudera.com/runtime/7.3.1/kafka-managing/topics/kafka-manage-mirrormaker.html>

## How are internal topics used to manage and track filtered or renamed topics

Kafka’s internal topics—those with names beginning with an underscore (_)—play a crucial role in managing, tracking, and supporting the behavior of advanced features, including topic filtering and renaming in tools like MirrorMaker 2. These internal topics are not intended for direct user interaction or modification, as doing so can disrupt the correct functioning of the platform.

**How Internal Topics Are Used:**

- **Tracking State and Metadata:**
  Internal topics are automatically created and managed by Kafka and its ecosystem tools (such as MirrorMaker 2 and Kafka Streams) to store metadata, checkpoints, state stores, and other operational information. For example, when topics are filtered or renamed during replication, internal topics may track which topics have been replicated, their original names, and their new names in the target cluster. This ensures consistency and prevents issues like replication loops.

- **Supporting Filtering and Renaming Logic:**
  When MirrorMaker 2 filters or renames topics, it relies on internal topics to maintain mappings and to record the state of replication. For instance, these topics can store information about which topics have already been processed, what their source and target names are, and any offset translation required for consumer failover. This is especially important in complex topologies or when bidirectional replication is configured.

- **Cycle Prevention and Consistency:**
  By leveraging internal topics, MirrorMaker 2 can prevent cycles (where a topic is replicated back and forth endlessly) and ensure that only the intended topics are replicated, even as filtering rules or renaming conventions change.

**Best Practices:**

- **Do Not Modify Internal Topics:**
  Internal topics should not be manually altered or deleted unless explicitly required and understood, as they are essential for the correct operation of Kafka and its replication tools.
- **Visibility and Management:**
  Kafka management tools (like Confluent Control Center) allow you to view but not modify internal topics, reinforcing their special status and critical operational role.

> "Internal topics names start with an underscore (_) and should not be individually modified. Modifying an internal topic could adversely impact your Confluent Platform installation and result in unexpected behavior."

**In summary:**
Internal topics in Kafka are foundational for tracking, managing, and ensuring the correctness of operations such as topic filtering and renaming in MirrorMaker 2. They store essential metadata and state, enabling robust, automated, and safe replication across clusters without user intervention.

- [1] <https://docs.confluent.io/platform/current/control-center/topics/overview.html>
- [2] <https://forum.confluent.io/t/understanding-internal-topics/13459>
- [3] <https://support.atlassian.com/platform-experiences/docs/categorize-goals-and-projects-with-topics/>
- [4] <https://docs.oracle.com/en/industries/life-sciences/empirica/9.2.3/userguide/overview-topic-management.html>
- [5] <https://www.manageengine.com/products/support-center/help/adminguide/solutions/manage-topics.html>
- [6] <https://docs.oracle.com/health-sciences/empirica-signal-811/ESIUG/About_Topics.htm>
- [7] <https://stackoverflow.com/questions/56080896/what-are-internal-topics-used-in-kafka>
- [8] <https://developer.confluent.io/courses/apache-kafka/topics/>

## Partition reassignment in Kafka

- Get current partition replica assignment, create `/tmp/topics.json`

  ```bash
  kubectl exec -n myproject kafka-data-kafka-0 -ti -- \
      /bin/sh -c 'echo "{ \"topics\" : [ {\"topic\": \"broker-topic\"}], \"version\": 1}" > /tmp/topics.json'
  ```

  ```bash
  kubectl exec -n myproject kafka-data-kafka-0 -it -- cat /tmp/topics.json
  ```

and generate reassignment configuration.

  ```bash
  kubectl exec -n myproject kafka-data-kafka-0 -it -- bin/kafka-reassign-partitions.sh \
      --broker-list "0,1,2" \
      --topics-to-move-json-file /tmp/topics.json \
      --bootstrap-server kafka-data-kafka-bootstrap:9092 --generate
  ```

- This commands generate json file like below. It includes current partition assignments. Keep that file in somewhere for rollback, just in case.

Current partition replica assignment

```json
{"version":1,"partitions":[{"topic":"broker-topic","partition":0,"replicas":[2,0,1],"log_dirs":["any","any","any"]},{"topic":"broker-topic","partition":1,"replicas":[1,2,0],"log_dirs":["any","any","any"]},{"topic":"broker-topic","partition":2,"replicas":[0,1,2],"log_dirs":["any","any","any"]}]}
```

Proposed partition reassignment configuration

```json
{"version":1,"partitions":[{"topic":"broker-topic","partition":0,"replicas":[2,0,1],"log_dirs":["any","any","any"]},{"topic":"broker-topic","partition":1,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"broker-topic","partition":2,"replicas":[1,2,0],"log_dirs":["any","any","any"]}]}
```

- Let’s add 2 more brokers and new partitions.

```bash
kubectl exec -n myproject kafka-data-kafka-0 -it -- bin/kafka-topics.sh --bootstrap-server kafka-data-kafka-bootstrap:9092 --topic broker-topic --alter --partitions 5
```

- Verify the partition reassignment configuration

```bash
kubectl exec -n myproject kafka-data-kafka-0 -it -- bin/kafka-topics.sh --bootstrap-server kafka-data-kafka-bootstrap:9092 --topic broker-topic --describe
```
