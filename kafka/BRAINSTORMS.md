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
