# Thoughts and Questions on Kafka

## What's the longest time till the subscriber stays with cluster after unsubscribing the kafka topic?

### Kafka Subscriber Retention After Unsubscribing

**Kafka does not have a direct "unsubscribe" operation for consumers.** Instead, consumers simply stop polling messages from a topic. The Kafka broker will retain information about the consumer group (including its offsets) for a specific period after the consumer stops consuming—this is governed by the `offsets.retention.minutes` configuration for consumer groups.

#### How Long Does a "Unsubscribed" Consumer Stay in the Cluster?

- **Consumer Offsets Retention:**
  When a consumer stops consuming (effectively "unsubscribing"), Kafka retains its committed offsets for a period defined by the `offsets.retention.minutes` broker configuration. By default, this is 7 days (10,080 minutes), but it can be configured[3].

- **Consumer Group Removal:**
  If no consumers in a group connect and commit offsets within this retention period, Kafka will automatically delete the stored offsets and metadata for that group after the retention window elapses.

- **Manual Deletion:**
  You can also explicitly delete a consumer group using Kafka admin tools, which immediately removes its metadata from the cluster.

#### Topic Data Retention

- **Message Retention:**
  The messages themselves are retained according to the topic's retention policy, typically set by `log.retention.hours` (default: 168 hours or 7 days), `log.retention.minutes`, or `log.retention.ms`. This is independent of consumer activity—messages are deleted based on time or size, not consumer presence.

#### Summary Table

| Retention Type          | Default Value  | Configurable By                       | What It Controls                                       |
|-------------------------|----------------|---------------------------------------|--------------------------------------------------------|
| Offsets Retention       | 7 days         | `offsets.retention.minutes`           | How long consumer group info is kept after last commit |
| Topic Message Retention | 7 days         | `log.retention.hours` (or minutes/ms) | How long messages remain in the topic                  |

#### Key Points

- After a consumer "unsubscribes" (stops consuming), its group information is retained for the duration set by `offsets.retention.minutes`.
- After this period with no activity, the subscriber (consumer group) is automatically removed from the cluster.
- Message retention is separate and governed by topic-level retention settings.

**In summary:**
The longest time a subscriber (consumer group) stays in the Kafka cluster after unsubscribing is determined by the `offsets.retention.minutes` setting, which defaults to 7 days but can be configured as needed.

- [1] <https://www.automq.com/blog/kafka-retention-policy-concept-best-practices>
- [2] <https://learn.conduktor.io/kafka/kafka-topic-configuration-log-retention/>
- [3] <https://www.reddit.com/r/apachekafka/comments/120to89/learning_kafka_question_on_unsubscribing_from_a/>
- [4] <https://stackoverflow.com/questions/16284399/is-there-a-way-to-purge-the-topic-in-kafka>
- [5] <https://community.cloudera.com/t5/Support-Questions/Kafka-Topic-based-Data-Retention-Period-setup-over-the/m-p/310933>
- [6] <https://www.reddit.com/r/apachekafka/comments/o9v7f8/how_much_longer_will_the_message_stay_in_kafka_if/>
- [7] <https://docs.confluent.io/platform/current/installation/configuration/topic-configs.html>
- [8] <https://www.redpanda.com/guides/kafka-alternatives-kafka-retention>

## Is Schema Registry Mandatory for Kafka?

No, it is not mandatory to use a schema registry when using Kafka. Kafka itself treats messages as opaque byte arrays and `does not enforce any schema or format` on the data being produced or consumed. The schema registry is an optional component that helps manage and enforce data schemas (such as Avro, Protobuf, or JSON Schema) between producers and consumers, ensuring compatibility and consistency as data evolves.

You typically need a schema registry only if:

- You are using a serialization format like Avro, Protobuf, or JSON Schema and want to manage schema versions and compatibility.
- Your data schema is `expected to change over time`, and you want to enforce contracts between producers and consumers.

If your data format is fixed or you use simple formats (such as `plain JSON` or `strings`) without evolving schemas, you can use Kafka without a schema registry.

- [1] <https://docs.confluent.io/platform/current/schema-registry/index.html>
- [2] <https://stackoverflow.com/questions/62397957/is-schema-registry-required-with-any-kafka-avro-set-up>
- [3] <https://docs.confluent.io/platform/current/schema-registry/faqs-cp.html>
- [4] <https://risingwave.com/blog/comprehensive-guide-to-kafka-schema-registry/>
- [5] <https://www.redpanda.com/guides/kafka-tutorial-kafka-schema-registry>
- [6] <https://cloud.google.com/managed-service-for-apache-kafka/docs/schema-registry/create-schema-registry>
- [7] <https://www.kai-waehner.de/blog/2023/10/16/data-quality-and-policy-enforcement-for-apache-kafka-with-schema-registry/>
- [8] <https://conduktor.io/blog/what-is-the-schema-registry-and-why-do-you-need-to-use-it>

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

## How Does a Kafka Subscriber Know When a New Update Arrives?

A Kafka subscriber (consumer) detects new updates by continuously polling the Kafka broker for new messages on its subscribed topics. This is a fundamental part of how Kafka's consumer API is designed.

### **Polling Mechanism:**

- After a consumer subscribes to one or more topics, it enters an infinite loop where it repeatedly calls the `poll()` method.
- Each poll checks the broker for any new messages that have been published to the subscribed topics since the last poll.
- If there are new messages, the broker returns them to the consumer, which can then process them as needed.

### **Key Points:**

- There is no push mechanism; Kafka does not notify consumers of new messages. Instead, consumers are responsible for asking (polling) for updates.
- This polling loop is typical in streaming applications, where data is expected to arrive continuously, and there is no concept of a "last" message.
- The consumer can adjust the polling interval (how frequently it checks for new messages) by configuring the duration passed to the `poll()` method.

### **Example (Java):**

```java
while (true) {
    ConsumerRecords records = consumer.poll(Duration.ofMillis(10));
    for (ConsumerRecord record : records) {
        // Process the new record (message)
    }
}
```

In this example, the consumer polls every 10 milliseconds for new updates.

### **Summary Table: Kafka Consumer Update Detection**

| Mechanism          | Description                                      |
|--------------------|--------------------------------------------------|
| Polling            | Consumer repeatedly calls `poll()` for new data  |
| No Push            | Kafka does not push updates to consumers         |
| Infinite Loop      | Consumer runs an endless loop to check for data  |
| Configurable Delay | Polling interval can be adjusted                 |

**Conclusion:**
A Kafka subscriber knows a new update has arrived because its polling call to the broker returns new messages. This continuous polling is the standard way for consumers to stay up-to-date with the latest data in Kafka topics.

- [1] <https://developer.confluent.io/courses/apache-kafka/consumers/>
- [2] <https://doc.akka.io/docs/alpakka-kafka/current/subscription.html>
- [3] <https://kafka.apache.org/28/javadoc/org/apache/kafka/clients/consumer/Consumer.html>
- [4] <https://www.youtube.com/watch?v=mHaVGVLyfB4>
- [5] <https://storm.apache.org/releases/1.2.3/javadocs/org/apache/storm/kafka/spout/Subscription.html>
- [6] <https://docs.oracle.com/en/database/oracle/oracle-database/23/okjdc/org/oracle/okafka/clients/consumer/KafkaConsumer.html>
- [7] <https://doc.akka.io/libraries/alpakka-kafka/current/consumer.html>
- [8] <https://www.youtube.com/watch?v=Z9g4jMQwog0>

## What does the Kafka consumer do when it receives a message?

When a Kafka consumer receives a message, it typically follows these steps:

1. **Polling for Messages**: The consumer continuously polls the Kafka broker for new messages using the `poll()` method. This method retrieves messages from the topics it is subscribed to.
2. **Processing Messages**: Once messages are received, the consumer processes them according to its application logic. This could involve:
   - Deserializing the message data (e.g., converting from bytes to a specific format like JSON or Avro).
   - Performing business logic based on the message content.
   - Storing the processed data in a database or another system.
3. **Committing Offsets**: After processing the messages, the consumer commits the offsets of the messages it has successfully processed. This is done to ensure that if the consumer restarts, it knows where to continue reading from. Offsets can be committed automatically or manually, depending on the consumer configuration.
4. **Error Handling**: If an error occurs during message processing, the consumer may:
   - Retry processing the message.
   - Log the error for later analysis.
   - Skip the message or move it to a dead-letter queue if it cannot be processed after several attempts.
5. **Continuing the Loop**: The consumer continues polling for new messages in a loop, repeating the above steps until it is stopped or interrupted.

### What happens if a Kafka consumer does not commit offsets?

If a Kafka consumer does not commit offsets after processing messages, several consequences can occur:

1. **Reprocessing Messages**: If the consumer crashes or is restarted without committing offsets, it will re-read and reprocess messages from the last committed offset. This can lead to duplicate processing of messages, which may not be desirable in all applications.
2. **Data Loss**: If the consumer fails to commit offsets and does not handle messages correctly, it may lose track of which messages have been processed, leading to potential data loss or inconsistencies in the application state.
3. **Increased Latency**: The consumer may experience increased latency as it repeatedly processes the same messages without moving forward in the topic.
4. **Consumer Group Rebalance**: If the consumer is part of a consumer group and does not commit offsets, it may cause issues during rebalancing. Other consumers in the group may not know which messages have been processed, leading to inefficiencies and potential message loss.
5. **Offset Retention**: Kafka retains committed offsets for a configurable period (default is 7 days). If offsets are not committed, the consumer group may be removed after this retention period, leading to the loss of the consumer group's state.
6. **Manual Offset Management**: If the consumer is configured to manage offsets manually, it must explicitly commit offsets after processing messages. Failing to do so means the consumer will not progress, and it will keep reprocessing the same messages indefinitely.

## Explain lines coming from describing kafka topics

When you describe a Kafka topic using the `kafka-topics.sh --describe` command, it provides detailed information about the topic's configuration and state. Here’s a breakdown of the key lines you might see in the output:

### Example Output

```bash
Topic: broker-topic     TopicId: VqFKdC5sTr2UaholaO9PSg PartitionCount: 3       ReplicationFactor: 3    Configs: min.insync.replicas=2,message.format.version=3.0-IV1
        Topic: broker-topic     Partition: 0    Leader: 2       Replicas: 2,0,1 Isr: 2,0,1      Elr: N/A        LastKnownElr: N/A
        Topic: broker-topic     Partition: 1    Leader: 1       Replicas: 1,2,0 Isr: 1,2,0      Elr: N/A        LastKnownElr: N/A
        Topic: broker-topic     Partition: 2    Leader: 0       Replicas: 0,1,2 Isr: 0,1,2      Elr: N/A        LastKnownElr: N/A
```

These lines are describing the metadata and current state of a Kafka topic called `broker-topic`. Here’s a breakdown of what each part means:

### General Topic Information

- **Topic:** `broker-topic`
- **TopicId:** `VqFKdC5sTr2UaholaO9PSg` (unique identifier for the topic)
- **PartitionCount:** 3 (the topic is split into 3 partitions)
- **ReplicationFactor:** 3 (each partition has 3 replicas, meaning its data is stored on 3 different brokers for fault tolerance)
- **Configs:**
  - `min.insync.replicas=2` (at least 2 replicas must be in sync for writes to succeed)
  - `message.format.version=3.0-IV1` (the message format version used for this topic)

---

### Per-Partition Details

For each partition, the following columns are shown:

- **Partition:** The partition number (0, 1, or 2)
- **Leader:** The broker ID currently acting as the leader for this partition. All read and write requests go to this broker for this partition.
- **Replicas:** The list of `broker IDs` that store a copy of this partition’s data (the first is the preferred leader).
- **Isr:** "**In-Sync Replicas**" — the brokers that are fully caught up with the leader and eligible to be promoted if the leader fails.
- **Elr/LastKnownElr:** Not applicable here (N/A); these columns can relate to "**Eligible Leader Replicas**," which are not used in this output.

#### Example (Partition 0)

- **Partition:** 0
- **Leader:** 2 (broker ID 2 is the leader for partition 0)
- **Replicas:** 2,0,1 (partition 0 is stored on brokers 2, 0, and 1)
- **Isr:** 2,0,1 (all three replicas are in sync and up-to-date)

This means that for partition 0, broker 2 is handling all requests, but if broker 2 fails, either broker 0 or 1 can take over because they are in sync.

| Partition | Leader | Replicas  | In-Sync Replicas (ISR) |
|-----------|--------|-----------|------------------------|
| 0         | 2      | 2,0,1     | 2,0,1                  |
| 1         | 1      | 1,2,0     | 1,2,0                  |
| 2         | 0      | 0,1,2     | 0,1,2                  |

### What This Tells You

- The topic is distributed across three partitions for parallelism and scalability.
- Each partition is replicated across three brokers for high availability.
- The "**leader**" column shows which broker is currently responsible for each partition.
- The "**replicas**" column lists all brokers holding a copy of the partition.
- The "**isr**" column shows which replicas are fully in sync and can take over if the leader fails.

This structure ensures that Kafka can handle failures and scale efficiently, distributing partitions and replicas across multiple brokers.

- [1] <https://linuxhint.com/apache-kafka-producer-partition-metadata-given-topic/>
- [2] <https://stackoverflow.com/questions/59617341/what-is-kafka-topics-sh-describe-showing-me>
- [3] <https://redhat-developer-demos.github.io/kafka-tutorial/kafka-tutorial/1.0.x/02-topics-partitions.html>
- [4] <https://www.cloudkarafka.com/blog/understanding-kafka-topics-and-partitions.html>
- [5] <https://stackoverflow.com/questions/37499349/understanding-kafka-partition-metadata>
- [6] <https://developer.confluent.io/faq/apache-kafka/topics-in-kafka/>
- [7] <https://dev.to/clasnake/what-are-topics-and-partitions-in-kafka-31i4>
- [8] <https://docs.confluent.io/kafka/introduction.html>
- [9] <https://kafka.apache.org/intro>
- [10] <https://kafka.apache.org/documentation/>
