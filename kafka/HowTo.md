# How To and setups particularly in Kafka

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

## How does Kafka store data?

Kafka stores data using a `distributed`, `partitioned`, and `replicated commit log` architecture designed for scalability, fault tolerance, and high throughput.

Here’s how it works:

### **Core Storage Concepts**

- **Topics and Partitions**: Data in Kafka is organized into *topics*, which are logical channels for messages. Each topic is divided into one or more *partitions*, allowing parallel processing and scalability. Each partition is an ordered, immutable sequence of messages.
- **Commit Log**: Each partition is stored as a commit log on disk. Messages are appended sequentially, ensuring order and immutability—records cannot be modified or deleted, only added.
- **Offsets**: Every message within a partition is assigned a unique, sequential *offset*. Consumers use these offsets to track their position in the log, enabling reliable recovery and replay.
- **Brokers**: Kafka brokers are servers responsible for storing partition data on their local file system. Each partition is stored as a `directory` on disk, and brokers handle both `read and write requests` for the partitions they manage.
- **Replication**: For fault tolerance, each partition is replicated across multiple brokers. One broker acts as the *leader* for each partition, handling all reads and writes, while others serve as *followers* and replicate the data.

### **Storage Management**

- **Retention Policies**: Kafka retains data on disk based on configurable policies—by time (e.g., keep data for 7 days) or by size (e.g., keep up to 1GB per partition). After the retention period or size is exceeded, older data is deleted.
- **Tiered Storage**: Recent Kafka versions support *tiered storage*, allowing older data to be offloaded from broker disks to cheaper, scalable storage (like cloud object stores), while recent data remains on local disks for fast access. This improves scalability and cost efficiency for large-scale deployments.

### **Summary Table**

| Component      | Storage Role                                            |
|----------------|---------------------------------------------------------|
| Topic          | Logical grouping of messages                            |
| Partition      | Ordered, immutable log; unit of parallelism             |
| Broker         | Stores partitions on disk; handles reads/writes         |
| Offset         | Unique ID for each message in a partition               |
| Replication    | Copies partitions to other brokers for fault tolerance  |
| Tiered Storage | Offloads older data to external storage (optional)      |

Kafka’s design—using partitioned, replicated commit logs stored on disk—enables high-throughput, reliable, and scalable data streaming.

- [1] <https://www.instaclustr.com/education/apache-kafka/apache-kafka-architecture-a-complete-guide-2025/>
- [2] <https://kafka.apache.org/20/documentation/streams/architecture>
- [3] <https://developer.confluent.io/courses/architecture/get-started/>
- [4] <https://rohithsankepally.github.io/Kafka-Storage-Internals/>
- [5] <https://aws.amazon.com/what-is/apache-kafka/>
- [6] <https://www.kai-waehner.de/blog/2023/12/05/why-tiered-storage-for-apache-kafka-is-a-big-thing/>
- [7] <https://www.site24x7.com/learn/apache-kafka-architecture.html>
- [8] <https://www.upsolver.com/blog/apache-kafka-architecture-what-you-need-to-know>
