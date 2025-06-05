# Kafka

**An open source distrubuted streaming platform, designed to handle large amounts of data by providing scalable, fault-tolerant, low-latency platform for processing in real-time.**

For building realtime architectures, realtime analytics, and streaming pipelines.

Kafka architecture is based on **`producer-subscriber`** model and follows distributed architecture, runs as cluster.

## Core Components of Kafka Architecture

1. **`Kafka Cluster`**: A Kafka cluster is a distributed system composed of multiple Kafka brokers working together to **handle the storage and processing of real-time streaming data.** It provides fault tolerance, scalability, and high availability for efficient data streaming and messaging in large-scale applications.

2. **`Brokers`**: Brokers are the servers that form the Kafka cluster. Each broker is responsible for **receiving, storing, and serving data.** They handle the read and write operations from `producers and consumers`. Brokers also manage the replication of data to ensure fault tolerance.

3. **`Topics and Partitions`**: Data in Kafka is organized into `topics`, which are **logical channels to which producers send data and from which consumers read data**. Each topic is divided into partitions, which are the basic unit of parallelism in Kafka. Partitions allow Kafka to **scale horizontally by distributing data across multiple brokers.**

4. **`Producers`**: Producers are client applications that **publish (write) data to Kafka topics.** They send records to the appropriate topic and partition based on `the partitioning strategy`, which can be `key-based` or `round-robin`.

5. **`Consumers`**: Consumers are client applications that **subscribe to Kafka topics and process the data.** They read records from the topics and can be part of a consumer group, which allows for load balancing and fault tolerance. **Each consumer in a group reads data from a unique set of partitions.**

6. **`ZooKeeper`**: ZooKeeper is a centralized service for **maintaining configuration information, naming, providing distributed synchronization, and providing group services.** In Kafka, ZooKeeper is used to **manage and coordinate the Kafka brokers**. ZooKeeper is shown as a `separate component` interacting with the Kafka cluster.

7. **`Offsets`** : Offsets are **unique identifiers assigned to each message in a partition.** Consumers will use these offsets to track their progress in consuming messages from a topic.

## Kafka APIs

Kafka provides several APIs to interact with the system:

1. **`Producer API`**: Allows applications to **send streams of data to topics** in the Kafka cluster. It handles the `serialization of data` and the `partitioning logic.`

2. **`Consumer API`**: Allows applications to **read streams of data from topics.** It manages `the offset of the data read`, ensuring that each record is processed exactly once.

3. **`Streams API`**: A Java library for building applications that **process data in real-time**. It allows for `powerful transformations and aggregations of event data.`

4. **`Connector API`**: Provides a framework for **connecting Kafka with external systems.** `Source connectors` import data from external systems into Kafka topics, while `sink connectors` export data from Kafka topics to external systems.

## Interactions in the Kafka Architecture

* **`Producers to Kafka Cluster`**: Producers send data to the Kafka cluster. The data is published to specific topics, which are then divided into partitions and distributed across the brokers.

* **`Kafka Cluster to Consumers`**: Consumers read data from the Kafka cluster. They subscribe to topics and consume data from the partitions assigned to them. The consumer group ensures that the load is balanced and that each partition is processed by only one consumer in the group.

* **`ZooKeeper to Kafka Cluster`**: ZooKeeper coordinates and manages the Kafka cluster. It keeps track of the cluster's metadata, manages broker configurations, and handles leader elections for partitions.

## Key Features of Kafka Architecture

1. **`High Throughput and Low Latency`**: Kafka is designed to handle high volumes of data with low latency. It can process millions of messages per second with latencies as low as 10 milliseconds.

2. **`Fault Tolerance`**: Kafka achieves fault tolerance through data replication. Each partition can have multiple replicas, and Kafka ensures that `data is replicated across multiple brokers.` This allows the system to continue operating even if some brokers fail.

3. **`Durability`**: Kafka ensures data durability by persisting data to disk. Data is stored in a `log-structured` format, which allows for efficient sequential reads and writes.

4. **`Scalability`**: Kafka's distributed architecture allows it to scale horizontally by **adding more brokers to the cluster.** This enables Kafka to handle increasing amounts of data without downtime.

5. **`Real-Time Processing`**: Kafka supports real-time data processing through its Streams API and `ksqlDB`, a streaming database that allows for **SQL-like queries on streaming data**.

## Real-World Kafka Architectures

* Apache Kafka is a versatile platform used in various real-world applications due to its high throughput, fault tolerance, and scalability.

1. **Pub-Sub Systems**

    In a publish-subscribe (pub-sub) system, **producers publish messages to topics, and consumers subscribe to those topics to receive the messages.** Kafka's architecture is well-suited for pub-sub systems due to its ability to handle high volumes of data and provide reliable message delivery.

    * **Key Components**

        * `Producers`: Applications that send data to Kafka topics.
        * `Topics`: Logical channels to which producers send data and from which consumers read data.
        * `Consumers`: Applications that subscribe to topics and process the data.
        * `Consumer Groups`: Groups of consumers that share the load of reading from topics.

    >A real-world example of a pub-sub system using Kafka could be a **news feed application** where multiple news sources (producers) publish articles to a topic, and various user applications (consumers) subscribe to receive updates in real-time.

2. **Stream Processing Pipelines**

    Stream processing pipelines involve **continuously ingesting, processing, and transforming data** in real-time. Kafka's ability to handle high-throughput data streams and its integration with stream processing frameworks like `Apache Flink` and `Apache Spark` make it ideal for building such pipelines.

    * **Key Components**

        * `Producers`: Applications that send raw data streams to Kafka topics.
        * `Topics`: Channels where raw data is stored before processing.
        * `Stream Processors`: Applications or frameworks that consume raw data, process it, and produce transformed data.
        * `Sink Topics`: Topics where processed data is stored for further use.

    >A real-world example of a stream processing pipeline using Kafka could be a **financial trading platform** where market data (producers) is ingested in real-time, processed to detect trading signals (stream processors), and the results are stored in sink topics for further analysis.

3. **Log Aggregation Architectures**

    Log aggregation involves **collecting log data from various sources, centralizing it, and making it available for analysis.** Kafka's durability and scalability make it an excellent choice for log aggregation systems.

    * **Key Components**

        * `Log Producers`: Applications or services that generate log data.
        * `Log Topics`: Kafka topics where log data is stored.
        * `Log Consumers`: Applications that read log data for analysis or storage in a centralized system.

    >A real-world example of a log aggregation architecture using Kafka could be a **microservices-based application** where each microservice produces logs. These logs are sent to Kafka topics, and a centralized logging system (like ELK Stack) consumes the logs for analysis and monitoring.

## Advantages of Kafka Architecture

* `Decoupling of Producers and Consumers`: Kafka decouples producers and consumers, allowing them to operate independently. This makes it easier to scale and manage the system.

* `Ordered and Immutable Logs`: Kafka maintains the order of records within a partition and ensures that records are immutable. This guarantees the integrity and consistency of the data.

* `High Availability`: Kafka's replication and fault tolerance mechanisms ensure high availability and reliability of the data.

<details>

<summary>Click to expand for more details on Kafka</summary>

## Replication in Kafka

### Who is Leader and Follower?

In **Apache Kafka**, each **partition** of a topic has one **leader** replica and multiple **follower** replicas:

* **Leader**: The leader is the single replica that handles all **read** and **write** operations for the partition. Producers send messages to the leader, and consumers read messages from the leader (with one exception, which we'll skip for now).

* **Follower**: Follower replicas are **read-only** and replicate data from the leader. They do not handle client requests directly but maintain a copy of the data to ensure **high availability** and **data durability**.

When a leader fails or becomes unavailable, Kafka automatically **elects a new leader** from the in-sync replicas (ISR). Follower replicas continue to fetch data from the new leader to stay up to date.

### What is an ISR?

**ISR** stands for **In-Sync Replicas**. In Apache Kafka, it refers to a set of replicas (brokers) that are in sync with the *leader replica* of a partition. These replicas have successfully replicated all the messages from the leader and are considered up-to-date.

Key points about ISR:

* **ISR list** contains all replicas that are in sync with the leader.
* If a replica falls behind (due to network issues, slow performance, or failure), it is **removed from the ISR list** (this is called an **ISR shrink**).
* When a replica catches up, it is **added back to the ISR list** (this is called an **ISR expand**).
* Producers typically send messages to the leader and require acknowledgments from a minimum number of replicas in the ISR (controlled by the `min.insync.replicas` configuration).

### What is `min.insync.replicas`?

When producers send messages to a Kafka topic, they typically send them to the leader replica of a partition. To ensure data durability and delivery guarantees, they can be configured to wait for acknowledgments from a minimum number of replicas in the ISR (In-Sync Replicas) list.

This minimum number of replicas is defined by the `min.insync.replicas` configuration. For example:

* If `min.insync.replicas` is set to 2, the producer will wait for acknowledgments from at least 2 replicas (the leader and at least one follower) before considering the message successfully written.
* If this number is not met (e.g., due to a broker failure), the producer may retry or fail based on its configuration.
This setting helps balance availability and durability depending on your system's requirements.

### What is `replica.lag.time.max.ms`?

**`replica.lag.time.max.ms`** defines the `maximum amount of time a follower replica can lag behind the leader replica before it is considered out of sync.`
This parameter is crucial for maintaining the health of the Kafka cluster and ensuring that all replicas are up-to-date with the leader.

* If a follower replica does not catch up to the leader within the specified time, it may be removed from the In-Sync Replicas (ISR) list.
* This can lead to data loss if the leader fails, as the `out-of-sync` replica may not have the latest messages.
* The default value for `replica.lag.time.max.ms` is 10 seconds (10000 milliseconds), but it can be adjusted based on the specific requirements of your Kafka deployment.
* Setting it lower will allow us to detect failures more quickly, but it may also lead to more frequent ISR changes and potential data loss if the follower is unable to catch up in time.

### What is `replica.lag.max.messages`?

**`replica.lag.max.messages`** defines the **maximum number of messages a follower replica can lag behind the leader replica before it is considered out of sync.**
This parameter is crucial for maintaining the health of the Kafka cluster and ensuring that all replicas are up-to-date with the leader.

### What is `acks=all`?

**`acks=all`** specifies how many acknowledgments the producer requires from the broker before considering a message as successfully sent.

* When `acks=all` is set, the producer will wait for acknowledgments from all in-sync replicas (ISRs) of the partition before considering the message as successfully sent.
* This ensures that the message is replicated to all in-sync replicas, providing a higher level of durability and fault tolerance.
* If any of the in-sync replicas fail to acknowledge the message, the producer will retry sending the message until it receives acknowledgments from all in-sync replicas or until a timeout occurs.

* Possible values can be:
  * `acks=0`: The producer does not wait for any acknowledgment from the broker.
  * `acks=1`: The producer waits for acknowledgment from the leader replica only.
  * `acks=all`: The producer waits for acknowledgment from all in-sync replicas.
  * `acks=-1`: This is equivalent to `acks=all` and waits for acknowledgment from all in-sync replicas.

* Usually the number of ISR is equal to the replication factor of the topic, but it can be less if some replicas are not in sync.

* Example: `min.insync.replicas=3` and `ReplicationFactor=4`
  * This allows our application to tolerate 1 broker failure, as long as the remaining 3 brokers are in sync.
  * If the number of in-sync replicas is less than `min.insync.replicas`, the producer will receive an error and may retry sending the message based on its configuration. (Exception: `NotEnoughReplicas`)
  * This setting is crucial for ensuring data durability and consistency in Kafka, especially in scenarios where high availability and fault tolerance are required.

### What is `replica.fetch.wait.max.ms`?

**`replica.fetch.wait.max.ms`** defines the maximum amount of time a follower replica will wait for new data from the leader replica before fetching it. This setting is crucial for controlling the replication lag and ensuring that follower replicas stay up-to-date with the leader.

* If the leader replica has no new data to send, the follower will wait for this duration before attempting to fetch data again.
* This parameter helps balance the trade-off between replication lag and resource utilization. A shorter wait time can reduce lag but may increase network traffic, while a longer wait time can lead to higher lag but lower network usage.
* The default value for `replica.fetch.wait.max.ms` is 500 ms (0.5 seconds).

### What is `replica.fetch.min.bytes`?

**`replica.fetch.min.bytes`** defines the minimum amount of data that a follower replica must fetch from the leader replica in a single request. This setting is crucial for controlling the efficiency of data replication and minimizing network overhead.

* If the amount of data available on the leader is less than this threshold, the follower will wait until enough data is available before fetching it.
* This parameter helps optimize network usage by ensuring that the follower does not make frequent requests for small amounts of data, which can lead to increased latency and reduced throughput.
* The default value for `replica.fetch.min.bytes` is 1 byte, meaning that the follower will fetch data as soon as it is available, regardless of the amount.
* If you set a higher value, the follower will wait until it has at least that much data to fetch, which can help reduce the number of requests and improve overall replication efficiency.

### What is `num.replica.fetchers`?

**`num.replica.fetchers`** defines the number of threads used by a broker to fetch data from leader replicas for replication purposes. This setting is crucial for controlling the efficiency and performance of data replication across the Kafka cluster.

* Each broker can have multiple partitions, and each partition may have multiple replicas. The `num.replica.fetchers` setting determines how many threads will be used to fetch data from the leader replicas for all partitions on that broker.
* Increasing the number of replica fetchers can improve the replication throughput, especially in scenarios where a broker has many partitions or high data volume.
* The default value for `num.replica.fetchers` is 1, meaning that a single thread will be used to fetch data from leader replicas. However, this can be increased based on the broker's hardware capabilities and the expected workload.

## Key Metrics in Kafka

Kafka provides various metrics to monitor the health and performance of the cluster. Some key metrics include:

* **`Messages In Per Second`**: The number of messages produced to the Kafka cluster per second. Understanding `the throughput of the system.`
* **`Messages Out Per Second`**: The number of messages consumed from the Kafka cluster per second. Understanding `the consumption rate of the system.`

* **`Bytes In Per Second`**: The total number of bytes produced to the Kafka cluster per second. Understanding `the data volume being processed.`
* **`Bytes Out Per Second`**: The total number of bytes consumed from the Kafka cluster per second. Understanding `the data volume being consumed.`

* **`Active Controller Count`**: The number of active controllers in the Kafka cluster.
* **`Under Replicated Partitions`**: The number of partitions that are not fully replicated. Identifying `potential data loss scenarios.`
* **`Offline Partitions Count`**: The number of partitions that are currently offline. Identifying `partitions that are not available for reading or writing.`
* **`Consumer Lag`**: The difference between the latest offset in a partition and the offset that a consumer has processed. Understanding `how far behind a consumer is in processing messages.`

* **`Producer Error Rate`**: The rate of errors encountered by producers when sending messages to the Kafka cluster.
* **`Consumer Error Rate`**: The rate of errors encountered by consumers when reading messages from the Kafka cluster.

* **`Request Latency`**: The time taken to process requests in the Kafka cluster. Understanding `the responsiveness of the system.`
* **`Network I/O`**: The amount of data sent and received over the network by the Kafka brokers. Understanding `the network load on the cluster.`
* **`Disk I/O`**: The amount of data read from and written to disk by the Kafka brokers. Understanding `the disk load on the cluster.`

* **`Cluster Metrics`**: Metrics related to the overall health and performance of the Kafka cluster, such as the `number of active brokers, the status of each broker, and the health of the cluster as a whole.`
* **`Replication Metrics`**: Metrics related to the replication process, such as the `time taken to replicate messages, the number of messages replicated, and the status of replication across brokers.`
* **`Controller Metrics`**: Metrics related to the Kafka controller, such as the `time taken to elect a new controller, the number of controller requests processed, and the status of controller operations.`
* **`Partition Metrics`**: Metrics related to individual partitions, such as the `number of messages in each partition, the status of each partition, and the health of each partition.`
* **`Topic Metrics`**: Metrics related to specific topics, such as the `number of partitions, the replication factor, and the status of each partition.`
* **`Broker Metrics`**: Metrics related to individual brokers, such as the `number of active connections, the status of each broker, and the health of each broker.`
* **`Consumer Group Metrics`**: Metrics related to consumer groups, such as the `number of active consumers, the lag for each consumer group, and the status of each consumer group.`

* **`ISR Shrink/Expand Metrics`**: Metrics related to the shrinking and expanding of the In-Sync Replicas (ISR) list, such as the `number of times the ISR list has shrunk or expanded, and the time taken for these operations.`
* **`Under Min ISR Partitions`**: The number of partitions that do not have the minimum number of in-sync replicas. Identifying `partitions that may not be fully available for reading or writing.`

</details>
