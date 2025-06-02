# Kafka

An open source distrubuted streaming platform, designed to handle large amounts of data by providing scalable, fault-tolerant, low-latency platform for processing in real-time,

For building realtime architectures, realtime analytics, and streaming pipelines.

Kafka architecture is based on producer-subscriber model and follows distributed architecture, runs as cluster.

## Core Components of Kafka Architecture

1. `Kafka Cluster`: A Kafka cluster is a distributed system composed of multiple Kafka brokers working together to **handle the storage and processing of real-time streaming data.** It provides fault tolerance, scalability, and high availability for efficient data streaming and messaging in large-scale applications.

2. `Brokers`: Brokers are the servers that form the Kafka cluster. Each broker is responsible for **receiving, storing, and serving data.** They handle the read and write operations from `producers` and `consumers`. Brokers also manage the replication of data to ensure fault tolerance.

3. `Topics and Partitions`: Data in Kafka is organized into `topics`, which are *logical channels to which producers send data* and *from which consumers read data*. Each topic is divided into partitions, which are the basic unit of parallelism in Kafka. Partitions allow Kafka to **scale horizontally by distributing data across multiple brokers.**

4. `Producers`: Producers are client applications that **publish (write) data to Kafka topics.** They send records to the appropriate topic and partition based on `the partitioning strategy`, which can be `key-based` or `round-robin`.

5. `Consumers`: Consumers are client applications that **subscribe to Kafka topics and process the data.** They read records from the topics and can be part of a consumer group, which allows for load balancing and fault tolerance. **Each consumer in a group reads data from a unique set of partitions.**

6. `ZooKeeper`: ZooKeeper is a centralized service for **maintaining configuration information, naming, providing distributed synchronization, and providing group services.** In Kafka, ZooKeeper is used to manage and coordinate the Kafka brokers. ZooKeeper is shown as a `separate component` interacting with the Kafka cluster.

7. `Offsets` : **Offsets are unique identifiers assigned to each message in a partition.** Consumers will use these offsets to track their progress in consuming messages from a topic.

## Kafka APIs

Kafka provides several APIs to interact with the system:

1. `Producer API`: Allows applications to **send streams of data to topics** in the Kafka cluster. It handles the `serialization of data` and the `partitioning logic.`

2. `Consumer API`: Allows applications to **read streams of data from topics.** It manages `the offset of the data read`, ensuring that each record is processed exactly once.

3. `Streams API`: A Java library for building applications that **process data in real-time**. It allows for `powerful transformations and aggregations of event data.`

4. `Connector API`: Provides a framework for **connecting Kafka with external systems.** `Source connectors` import data from external systems into Kafka topics, while `sink connectors` export data from Kafka topics to external systems.

## Interactions in the Kafka Architecture

* `Producers to Kafka Cluster`: Producers send data to the Kafka cluster. The data is published to specific topics, which are then divided into partitions and distributed across the brokers.

* `Kafka Cluster to Consumers`: Consumers read data from the Kafka cluster. They subscribe to topics and consume data from the partitions assigned to them. The consumer group ensures that the load is balanced and that each partition is processed by only one consumer in the group.

* `ZooKeeper to Kafka Cluster`: ZooKeeper coordinates and manages the Kafka cluster. It keeps track of the cluster's metadata, manages broker configurations, and handles leader elections for partitions.

## Key Features of Kafka Architecture

1. `High Throughput and Low Latency`: Kafka is designed to handle high volumes of data with low latency. It can process millions of messages per second with latencies as low as 10 milliseconds.

2. `Fault Tolerance`: Kafka achieves fault tolerance through data replication. Each partition can have multiple replicas, and Kafka ensures that `data is replicated across multiple brokers.` This allows the system to continue operating even if some brokers fail.

3. `Durability`: Kafka ensures data durability by persisting data to disk. Data is stored in a `log-structured` format, which allows for efficient sequential reads and writes.

4. `Scalability`: Kafka's distributed architecture allows it to scale horizontally by **adding more brokers to the cluster.** This enables Kafka to handle increasing amounts of data without downtime.

5. `Real-Time Processing`: Kafka supports real-time data processing through its Streams API and `ksqlDB`, a streaming database that allows for **SQL-like queries on streaming data**.

## Real-World Kafka Architectures

* Apache Kafka is a versatile platform used in various real-world applications due to its high throughput, fault tolerance, and scalability.

1. Pub-Sub Systems
    In a publish-subscribe (pub-sub) system, **producers publish messages to topics, and consumers subscribe to those topics to receive the messages.** Kafka's architecture is well-suited for pub-sub systems due to its ability to handle high volumes of data and provide reliable message delivery.

    * Key Components

        * `Producers`: Applications that send data to Kafka topics.
        * `Topics`: Logical channels to which producers send data and from which consumers read data.
        * `Consumers`: Applications that subscribe to topics and process the data.
        * `Consumer Groups`: Groups of consumers that share the load of reading from topics.

    >A real-world example of a pub-sub system using Kafka could be a *news feed application* where multiple news sources (producers) publish articles to a topic, and various user applications (consumers) subscribe to receive updates in real-time.

2. Stream Processing Pipelines
    Stream processing pipelines involve **continuously ingesting, processing, and transforming data** in real-time. Kafka's ability to handle high-throughput data streams and its integration with stream processing frameworks like `Apache Flink` and `Apache Spark` make it ideal for building such pipelines.

    * Key Components

        * `Producers`: Applications that send raw data streams to Kafka topics.
        * `Topics`: Channels where raw data is stored before processing.
        * `Stream Processors`: Applications or frameworks that consume raw data, process it, and produce transformed data.
        * `Sink Topics`: Topics where processed data is stored for further use.

    >A real-world example of a stream processing pipeline using Kafka could be a *financial trading platform* where market data (producers) is ingested in real-time, processed to detect trading signals (stream processors), and the results are stored in sink topics for further analysis.

3. Log Aggregation Architectures
    Log aggregation involves **collecting log data from various sources, centralizing it, and making it available for analysis.** Kafka's durability and scalability make it an excellent choice for log aggregation systems.

    * Key Components

        * `Log Producers`: Applications or services that generate log data.
        * `Log Topics`: Kafka topics where log data is stored.
        * `Log Consumers`: Applications that read log data for analysis or storage in a centralized system.

    >A real-world example of a log aggregation architecture using Kafka could be a *microservices-based application* where each microservice produces logs. These logs are sent to Kafka topics, and a centralized logging system (like ELK Stack) consumes the logs for analysis and monitoring.

## Advantages of Kafka Architecture

* `Decoupling of Producers and Consumers`: Kafka decouples producers and consumers, allowing them to operate independently. This makes it easier to scale and manage the system.

* `Ordered and Immutable Logs`: Kafka maintains the order of records within a partition and ensures that records are immutable. This guarantees the integrity and consistency of the data.

* `High Availability`: Kafka's replication and fault tolerance mechanisms ensure high availability and reliability of the data.
