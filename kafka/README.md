# Kafka

**An open source distrubuted streaming platform, designed to handle large amounts of data by providing scalable, fault-tolerant, low-latency platform for processing in real-time.**

For building realtime architectures, realtime analytics, and streaming pipelines.

Kafka architecture is based on **`producer-subscriber`** model and follows distributed architecture, runs as cluster.

## Index

- [Core Components of Kafka Architecture](#core-components-of-kafka-architecture)
- [Kafka APIs](#kafka-apis)
- [Interactions in the Kafka Architecture](#interactions-in-the-kafka-architecture)
- [Key Features of Kafka Architecture](#key-features-of-kafka-architecture)
- [Real-World Kafka Architectures](#real-world-kafka-architectures)
- [Advantages of Kafka Architecture](#advantages-of-kafka-architecture)
- [Replication in Kafka](#replication-in-kafka)
- [Key Metrics in Kafka](#key-metrics-in-kafka)
- [Security in Kafka](#security-in-kafka)
- [What are Kafka Connectors?](#what-are-kafka-connectors)
- [Important feature/configuirations in Kafka](#important-featureconfigurations-in-kafka)
- [Strimzi Operators](#strimzi-operator)
- [Kafka Tuning](#kafka-high-performance-tuning)
- [Kafka Backup](#backup-of-kafka-data-and-configurations)
- [Kafka MirrorMaker](#what-is-kafka-mirrormaker)

## Core Components of Kafka Architecture

![Kafka Architecture](https://www.cloudkarafka.com/img/blog/apache-kafka-partition.png "Kafka Architecture")
From _[hevodata.com](https://hevodata.com/learn/kafka-topic/)_

![Kafka Architecture](https://strimzi.io/docs/operators/latest/images/overview/kafka-concepts-supporting-components.png "Kafka Architecture")
From _[strimzi.io](https://strimzi.io/docs/operators/latest/overview.html)_

1. **`Kafka Cluster`**: A Kafka cluster is a distributed system composed of multiple Kafka brokers working together to **handle the storage and processing of real-time streaming data.** It provides fault tolerance, scalability, and high availability for efficient data streaming and messaging in large-scale applications.

2. **`Brokers`**: Brokers are the servers that form the Kafka cluster. Each broker is responsible for **receiving, storing, and serving data.** They handle the read and write operations from `producers and consumers`. Brokers also manage the replication of data to ensure fault tolerance.

    ![Kafka Brokers](https://res.cloudinary.com/hevo/images/c_scale,w_448,h_170/f_webp,q_auto:best/v1709656054/hevo-learn-1/kafka-topics-2_1873330e242/kafka-topics-2_1873330e242.png?_i=AA)
    From _[hevodata.com](https://hevodata.com/learn/kafka-topic/)_

3. **`Topics and Partitions`**: Data in Kafka is organized into `topics`, which are **logical channels to which producers send data and from which consumers read data**. Each topic is divided into partitions, which are the basic unit of parallelism in Kafka. Partitions allow Kafka to **scale horizontally by distributing data across multiple brokers.**

    ![Kafka Topics](https://res.cloudinary.com/hevo/images/c_scale,w_648,h_336/f_webp,q_auto:best/v1705316196/hevo-learn-1/streams-and-tables-p1_p4_nmkgsy/streams-and-tables-p1_p4_nmkgsy.webp?_i=AA "Kafka Topics")
    From _[hevodata.com](https://hevodata.com/learn/kafka-topic/)_

4. **`Producers`**: Producers are client applications that **publish (write) data to Kafka topics.** They send records to the appropriate topic and partition based on `the partitioning strategy`, which can be `key-based` or `round-robin`.

5. **`Consumers`**: Consumers are client applications that **subscribe to Kafka topics and process the data.** They read records from the topics and can be part of a consumer group, which allows for load balancing and fault tolerance. **Each consumer in a group reads data from a unique set of partitions.**

6. **`ZooKeeper`**: ZooKeeper is a centralized service for **maintaining configuration information, naming, providing distributed synchronization, and providing group services.** In Kafka, ZooKeeper is used to **manage and coordinate the Kafka brokers**. ZooKeeper is shown as a `separate component` interacting with the Kafka cluster.

    ![ZooKeeper](https://imgix.datadoghq.com/img/blog/monitoring-kafka-performance-metrics/kafka-diagram.jpg?auto=compress%2Cformat&cs=origin&lossless=true&fit=max&q=75&w=1400&dpr=1)
    From _[Datadog](https://www.datadoghq.com/blog/monitoring-kafka-performance-metrics/)_

7. **`Offsets`** : Offsets are **unique identifiers assigned to each message in a partition.** Consumers will use these offsets to track their progress in consuming messages from a topic.

## Kafka APIs

Kafka provides several APIs to interact with the system:

1. **`Producer API`**: Allows applications to **send streams of data to topics** in the Kafka cluster. It handles the `serialization of data` and the `partitioning logic.`

2. **`Consumer API`**: Allows applications to **read streams of data from topics.** It manages `the offset of the data read`, ensuring that each record is processed exactly once.

3. **`Streams API`**: A Java library for building applications that **process data in real-time**. It allows for `powerful transformations and aggregations of event data.`

4. **`Connector API`**: Provides a framework for **connecting Kafka with external systems.** `Source connectors` import data from external systems into Kafka topics, while `sink connectors` export data from Kafka topics to external systems.

## Interactions in the Kafka Architecture

- **`Producers to Kafka Cluster`**: Producers send data to the Kafka cluster. The data is published to specific topics, which are then divided into partitions and distributed across the brokers.

- **`Kafka Cluster to Consumers`**: Consumers read data from the Kafka cluster. They subscribe to topics and consume data from the partitions assigned to them. The consumer group ensures that the load is balanced and that each partition is processed by only one consumer in the group.

- **`ZooKeeper to Kafka Cluster`**: ZooKeeper coordinates and manages the Kafka cluster. It keeps track of the cluster's metadata, manages broker configurations, and handles leader elections for partitions.

## Key Features of Kafka Architecture

1. **`High Throughput and Low Latency`**: Kafka is designed to handle high volumes of data with low latency. It can process millions of messages per second with latencies as low as 10 milliseconds.

2. **`Fault Tolerance`**: Kafka achieves fault tolerance through data replication. Each partition can have multiple replicas, and Kafka ensures that `data is replicated across multiple brokers.` This allows the system to continue operating even if some brokers fail.

3. **`Durability`**: Kafka ensures data durability by persisting data to disk. Data is stored in a `log-structured` format, which allows for efficient sequential reads and writes.

4. **`Scalability`**: Kafka's distributed architecture allows it to scale horizontally by **adding more brokers to the cluster.** This enables Kafka to handle increasing amounts of data without downtime.

5. **`Real-Time Processing`**: Kafka supports real-time data processing through its Streams API and `ksqlDB`, a streaming database that allows for **SQL-like queries on streaming data**.

## Real-World Kafka Architectures

- Apache Kafka is a versatile platform used in various real-world applications due to its high throughput, fault tolerance, and scalability.

1. **Pub-Sub Systems**

    In a publish-subscribe (pub-sub) system, **producers publish messages to topics, and consumers subscribe to those topics to receive the messages.** Kafka's architecture is well-suited for pub-sub systems due to its ability to handle high volumes of data and provide reliable message delivery.

    - **Key Components**

        - `Producers`: Applications that send data to Kafka topics.
        - `Topics`: Logical channels to which producers send data and from which consumers read data.
        - `Consumers`: Applications that subscribe to topics and process the data.
        - `Consumer Groups`: Groups of consumers that share the load of reading from topics.

    >A real-world example of a pub-sub system using Kafka could be a **news feed application** where multiple news sources (producers) publish articles to a topic, and various user applications (consumers) subscribe to receive updates in real-time.

2. **Stream Processing Pipelines**

    Stream processing pipelines involve **continuously ingesting, processing, and transforming data** in real-time. Kafka's ability to handle high-throughput data streams and its integration with stream processing frameworks like `Apache Flink` and `Apache Spark` make it ideal for building such pipelines.

    - **Key Components**

        - `Producers`: Applications that send raw data streams to Kafka topics.
        - `Topics`: Channels where raw data is stored before processing.
        - `Stream Processors`: Applications or frameworks that consume raw data, process it, and produce transformed data.
        - `Sink Topics`: Topics where processed data is stored for further use.

    >A real-world example of a stream processing pipeline using Kafka could be a **financial trading platform** where market data (producers) is ingested in real-time, processed to detect trading signals (stream processors), and the results are stored in sink topics for further analysis.

3. **Log Aggregation Architectures**

    Log aggregation involves **collecting log data from various sources, centralizing it, and making it available for analysis.** Kafka's durability and scalability make it an excellent choice for log aggregation systems.

    - **Key Components**

        - `Log Producers`: Applications or services that generate log data.
        - `Log Topics`: Kafka topics where log data is stored.
        - `Log Consumers`: Applications that read log data for analysis or storage in a centralized system.

    >A real-world example of a log aggregation architecture using Kafka could be a **microservices-based application** where each microservice produces logs. These logs are sent to Kafka topics, and a centralized logging system (like ELK Stack) consumes the logs for analysis and monitoring.

## Advantages of Kafka Architecture

- `Decoupling of Producers and Consumers`: Kafka decouples producers and consumers, allowing them to operate independently. This makes it easier to scale and manage the system.

- `Ordered and Immutable Logs`: Kafka maintains the order of records within a partition and ensures that records are immutable. This guarantees the integrity and consistency of the data.

- `High Availability`: Kafka's replication and fault tolerance mechanisms ensure high availability and reliability of the data.

## Replication in Kafka

### Who is Leader and Follower?

In **Apache Kafka**, each **partition** of a topic has one **leader** replica and multiple **follower** replicas:

![Kafka Leader and Follower](https://mbukowicz.github.io/images/replication-in-kafka/leaders-followers.png "Kafka Leader and Follower")<br/>
From _[mbukowicz.github.io](https://mbukowicz.github.io/replication-in-kafka/)_

<!-- ![Kafka Partition Leader and follower](https://imgix.datadoghq.com/img/blog/monitoring-kafka-performance-metrics/broker-topic-partition2.png?auto=compress%2Cformat&cs=origin&lossless=true&fit=max&q=75&w=1400&dpr=1)
From _[Datadog](https://www.datadoghq.com/blog/monitoring-kafka-performance-metrics/)_ -->

- **Leader**: The leader is the single replica that handles all **read** and **write** operations for the partition. Producers send messages to the leader, and consumers read messages from the leader (with one exception, which we'll skip for now).

- **Follower**: Follower replicas are **read-only** and replicate data from the leader. They do not handle client requests directly but maintain a copy of the data to ensure **high availability** and **data durability**.

    When a leader fails or becomes unavailable, Kafka automatically **elects a new leader** from the in-sync replicas (ISR). Follower replicas continue to fetch data from the new leader to stay up to date.

### What is an ISR?

**ISR** stands for **In-Sync Replicas**. In Apache Kafka, it refers to a set of replicas (brokers) that are in sync with the _leader replica_ of a partition. These replicas have successfully replicated all the messages from the leader and are considered up-to-date.

![ISR Kafka](https://pic4.zhimg.com/v2-0cb9b66cdb1e6028d13b644cba19e703_r.jpg "Kafka ISR")
From _[zhihu.com](https://zhuanlan.zhihu.com/p/35088564)_

Key points about ISR:

- **ISR list** contains all replicas that are in sync with the leader.
- If a replica falls behind (due to network issues, slow performance, or failure), it is **removed from the ISR list** (this is called an **ISR shrink**).
- When a replica catches up, it is **added back to the ISR list** (this is called an **ISR expand**).
- Producers typically send messages to the leader and require acknowledgments from a minimum number of replicas in the ISR (controlled by the `min.insync.replicas` configuration).

### What is `min.insync.replicas`?

When producers send messages to a Kafka topic, they typically send them to the leader replica of a partition. To ensure data durability and delivery guarantees, they can be configured to wait for acknowledgments from a minimum number of replicas in the ISR (In-Sync Replicas) list.

This minimum number of replicas is defined by the `min.insync.replicas` configuration. For example:

- If `min.insync.replicas` is set to 2, the producer will wait for acknowledgments from at least 2 replicas (the leader and at least one follower) before considering the message successfully written.
- If this number is not met (e.g., due to a broker failure), the producer may retry or fail based on its configuration.
This setting helps balance availability and durability depending on your system's requirements.

### What is `replica.lag.time.max.ms`?

**`replica.lag.time.max.ms`** defines the `maximum amount of time a follower replica can lag behind the leader replica before it is considered out of sync.`
This parameter is crucial for maintaining the health of the Kafka cluster and ensuring that all replicas are up-to-date with the leader.

- If a follower replica does not catch up to the leader within the specified time, it may be removed from the In-Sync Replicas (ISR) list.
- This can lead to data loss if the leader fails, as the `out-of-sync` replica may not have the latest messages.
- The default value for `replica.lag.time.max.ms` is 10 seconds (10000 milliseconds), but it can be adjusted based on the specific requirements of your Kafka deployment.
- Setting it lower will allow us to detect failures more quickly, but it may also lead to more frequent ISR changes and potential data loss if the follower is unable to catch up in time.

### What is `replica.lag.max.messages`?

**`replica.lag.max.messages`** defines the **maximum number of messages a follower replica can lag behind the leader replica before it is considered out of sync.**
This parameter is crucial for maintaining the health of the Kafka cluster and ensuring that all replicas are up-to-date with the leader.

### What is `acks=all`?

**`acks=all`** specifies how many acknowledgments the producer requires from the broker before considering a message as successfully sent.

- When `acks=all` is set, the producer will wait for acknowledgments from all in-sync replicas (ISRs) of the partition before considering the message as successfully sent.
- This ensures that the message is replicated to all in-sync replicas, providing a higher level of durability and fault tolerance.
- If any of the in-sync replicas fail to acknowledge the message, the producer will retry sending the message until it receives acknowledgments from all in-sync replicas or until a timeout occurs.

- Possible values can be:
  - `acks=0`: The producer does not wait for any acknowledgment from the broker.
  - `acks=1`: The producer waits for acknowledgment from the leader replica only.
  - `acks=all`: The producer waits for acknowledgment from all in-sync replicas.
  - `acks=-1`: This is equivalent to `acks=all` and waits for acknowledgment from all in-sync replicas.

- Usually the number of ISR is equal to the replication factor of the topic, but it can be less if some replicas are not in sync.

- Example: `min.insync.replicas=3` and `ReplicationFactor=4`
  - This allows our application to tolerate 1 broker failure, as long as the remaining 3 brokers are in sync.
  - If the number of in-sync replicas is less than `min.insync.replicas`, the producer will receive an error and may retry sending the message based on its configuration. (Exception: `NotEnoughReplicas`)
  - This setting is crucial for ensuring data durability and consistency in Kafka, especially in scenarios where high availability and fault tolerance are required.

### What is `replica.fetch.wait.max.ms`?

**`replica.fetch.wait.max.ms`** defines the maximum amount of time a follower replica will wait for new data from the leader replica before fetching it. This setting is crucial for controlling the replication lag and ensuring that follower replicas stay up-to-date with the leader.

- If the leader replica has no new data to send, the follower will wait for this duration before attempting to fetch data again.
- This parameter helps balance the trade-off between replication lag and resource utilization. A shorter wait time can reduce lag but may increase network traffic, while a longer wait time can lead to higher lag but lower network usage.
- The default value for `replica.fetch.wait.max.ms` is 500 ms (0.5 seconds).

### What is `replica.fetch.min.bytes`?

**`replica.fetch.min.bytes`** defines the minimum amount of data that a follower replica must fetch from the leader replica in a single request. This setting is crucial for controlling the efficiency of data replication and minimizing network overhead.

- If the amount of data available on the leader is less than this threshold, the follower will wait until enough data is available before fetching it.
- This parameter helps optimize network usage by ensuring that the follower does not make frequent requests for small amounts of data, which can lead to increased latency and reduced throughput.
- The default value for `replica.fetch.min.bytes` is 1 byte, meaning that the follower will fetch data as soon as it is available, regardless of the amount.
- If you set a higher value, the follower will wait until it has at least that much data to fetch, which can help reduce the number of requests and improve overall replication efficiency.

### What is `num.replica.fetchers`?

**`num.replica.fetchers`** defines the number of threads used by a broker to fetch data from leader replicas for replication purposes. This setting is crucial for controlling the efficiency and performance of data replication across the Kafka cluster.

- Each broker can have multiple partitions, and each partition may have multiple replicas. The `num.replica.fetchers` setting determines how many threads will be used to fetch data from the leader replicas for all partitions on that broker.
- Increasing the number of replica fetchers can improve the replication throughput, especially in scenarios where a broker has many partitions or high data volume.
- The default value for `num.replica.fetchers` is 1, meaning that a single thread will be used to fetch data from leader replicas. However, this can be increased based on the broker's hardware capabilities and the expected workload.

## Key Metrics in Kafka

Kafka provides various metrics to monitor the health and performance of the cluster. Some key metrics include:

- **`Messages In Per Second`**: The number of messages produced to the Kafka cluster per second. Understanding `the throughput of the system.`
- **`Messages Out Per Second`**: The number of messages consumed from the Kafka cluster per second. Understanding `the consumption rate of the system.`

- **`Bytes In Per Second`**: The total number of bytes produced to the Kafka cluster per second. Understanding `the data volume being processed.`
- **`Bytes Out Per Second`**: The total number of bytes consumed from the Kafka cluster per second. Understanding `the data volume being consumed.`

- **`Active Controller Count`**: The number of active controllers in the Kafka cluster.
- **`Under Replicated Partitions`**: The number of partitions that are not fully replicated. Identifying `potential data loss scenarios.`
- **`Offline Partitions Count`**: The number of partitions that are currently offline. Identifying `partitions that are not available for reading or writing.`
- **`Consumer Lag`**: The difference between the latest offset in a partition and the offset that a consumer has processed. Understanding `how far behind a consumer is in processing messages.`

- **`Producer Error Rate`**: The rate of errors encountered by producers when sending messages to the Kafka cluster.
- **`Consumer Error Rate`**: The rate of errors encountered by consumers when reading messages from the Kafka cluster.

- **`Request Latency`**: The time taken to process requests in the Kafka cluster. Understanding `the responsiveness of the system.`
- **`Network I/O`**: The amount of data sent and received over the network by the Kafka brokers. Understanding `the network load on the cluster.`
- **`Disk I/O`**: The amount of data read from and written to disk by the Kafka brokers. Understanding `the disk load on the cluster.`

- **`Cluster Metrics`**: Metrics related to the overall health and performance of the Kafka cluster, such as the `number of active brokers, the status of each broker, and the health of the cluster as a whole.`
- **`Replication Metrics`**: Metrics related to the replication process, such as the `time taken to replicate messages, the number of messages replicated, and the status of replication across brokers.`
- **`Controller Metrics`**: Metrics related to the Kafka controller, such as the `time taken to elect a new controller, the number of controller requests processed, and the status of controller operations.`
- **`Partition Metrics`**: Metrics related to individual partitions, such as the `number of messages in each partition, the status of each partition, and the health of each partition.`
- **`Topic Metrics`**: Metrics related to specific topics, such as the `number of partitions, the replication factor, and the status of each partition.`
- **`Broker Metrics`**: Metrics related to individual brokers, such as the `number of active connections, the status of each broker, and the health of each broker.`
- **`Consumer Group Metrics`**: Metrics related to consumer groups, such as the `number of active consumers, the lag for each consumer group, and the status of each consumer group.`

- **`ISR Shrink/Expand Metrics`**: Metrics related to the shrinking and expanding of the In-Sync Replicas (ISR) list, such as the `number of times the ISR list has shrunk or expanded, and the time taken for these operations.`
- **`Under Min ISR Partitions`**: The number of partitions that do not have the minimum number of in-sync replicas. Identifying `partitions that may not be fully available for reading or writing.`

### References

- BLOG - [Datadog](https://www.datadoghq.com/blog/monitoring-kafka-performance-metrics/)
- DOCUMENTATION - [Apache Kafka](https://kafka.apache.org/documentation/#monitoring)
- DOCUMENTATION - [Confluent](https://docs.confluent.io/platform/current/monitoring/kafka-monitoring.html)

## Security in Kafka

### SASL

SASL `(Simple Authentication and Security Layer)` is a security protocol supported by Kafka, in addition to SSL (Secure Sockets Layer).

![SASL](https://images.ctfassets.net/gt6dp23g0g38/5Wg6QMjsyCxBJ1rKJ936qB/12f7a3e3ecbf3ec1ff4de1645946b2b9/sasl-ssl-kafka.jpg)
From _[Confluent](https://www.confluent.io/blog/)_

The key points about SASL are:

1. **Encryption**: Like SSL, SASL SSL encrypts the traffic between `Kafka clients and brokers` using the TLS cryptographic protocol.

2. **Authentication**: While SSL uses client certificates for authentication, SASL provides alternative authentication mechanisms such as:
   - GSSAPI (Kerberos)
   - PLAIN (username/password)
   - SCRAM-SHA-256 and SCRAM-SHA-512 (salted challenge response authentication mechanism)
   - OAUTHBEARER (OAuth 2.0 token-based authentication)

3. **Integration with Existing Infrastructure**: The main reason to choose SASL over SSL is to integrate Kafka with an existing authentication infrastructure in the organization, such as Kerberos, password servers, or OAuth providers.

4. **Configuration Overhead**: Each SASL mechanism has its own configuration requirements, often involving integration with external servers and services.

In summary, SASL provides an alternative to SSL-based authentication in Kafka, allowing integration with existing security infrastructure in the organization, at the cost of additional configuration complexity.

#### How it differs from SSL?

The key differences between SASL and SSL/TLS in the context of Apache Kafka are:

1. **Authentication Mechanism**:
   - **SSL/TLS**: Uses client certificates for authentication. Clients and brokers authenticate each other using X.509 certificates.
   - **SASL**: Supports various authentication mechanisms, such as Kerberos (GSSAPI), username/password (PLAIN), salted challenge-response (SCRAM), and OAuth (OAUTHBEARER).

2. **Integration with Existing Infrastructure**:
   - **SSL/TLS**: Requires managing and distributing client certificates, which can be more complex to integrate with existing authentication systems.
   - **SASL**: Allows integration with existing authentication infrastructure, such as Kerberos, LDAP, or OAuth providers, making it easier to leverage existing user credentials and authentication workflows.

3. **Encryption**:
   - **SSL/TLS**: Provides encryption of the communication between Kafka clients and brokers using the TLS protocol.
   - **SASL**: Does not provide encryption by itself. SASL is often used in conjunction with SSL/TLS to provide both authentication and encryption.

4. **Configuration Complexity**:
   - **SSL/TLS**: Requires configuring SSL/TLS certificates, trust stores, and related settings on both the client and broker side.
   - **SASL**: Requires configuring the specific SASL mechanism, including integration with external authentication systems, which can be more complex than SSL/TLS.

5. **Performance**:
   - **SSL/TLS**: Adds some overhead due to the cryptographic operations required for encryption and authentication.
   - **SASL**: Adds less overhead compared to SSL/TLS, as the authentication process is generally less computationally intensive.

In summary, SSL/TLS focuses on `providing encryption and certificate-based authentication`, while SASL offers more flexibility in terms of authentication mechanisms, allowing integration with existing authentication infrastructure.

### Enabling SASL Authentication in Kafka

Kafka supports various authentication mechanisms, and one of those is **SASL (Simple Authentication and Security Layer)**. Enabling SASL authentication adds a layer of security, ensuring that **only authenticated users or systems can publish or consume messages.**

1. Configure the Kafka broker
    - Edit the `server.properties` file in the Kafka configuration directory (usually located at `/etc/kafka` or `/opt/kafka/config`).
    - Add the following lines to enable SASL authentication:

    **server.properties**

    ```properties
    listeners=SASL_PLAINTEXT://:9092
    security.inter.broker.protocol=SASL_PLAINTEXT # Do not include any encryption, use SASL_SSL for encrypted communication
    sasl.mechanism.inter.broker.protocol=PLAIN # Use PLAIN mechanism for inter-broker communication
    sasl.enabled.mechanisms=PLAIN # Enable PLAIN mechanism for client authentication
    ```

2. Create a JAAS config file
    - Create a file named `kafka_server_jaas.conf` in the Kafka configuration directory and reference it in Kafka start-up by setting the `KAFKA_OPTS` environment variable.
    - Add the following lines to define the SASL authentication mechanism and user credentials:

    **kafka_server_jaas.conf** - Every user mentioned in this file can authenticate using the designated password. The same file is also used to authenticate inter-broker communication with the admin user’s credentials.

    ```properties
    KafkaServer {
        org.apache.kafka.common.security.plain.PlainLoginModule required
        username="admin" # Replace with your desired username
        password="admin-secret" # Replace with your desired password
        user_admin="admin-secret"; # Define user credentials
        user_alice="alice-secret"; # Define another user
    };

    KafkaClient {
      org.apache.kafka.common.security.plain.PlainLoginModule required
      username="alice"
      password="alice-secret";
    };
    ```

    ```bash
    export KAFKA_OPTS="-Djava.security.auth.login.config=/path/to/kafka_server_jaas.conf"
    ```

3. Start the Kafka broker
    - If everything is set up right, your Kafka server should boot up and be secured with SASL/PLAIN authentication.
    - Start the Kafka broker using the following command:

    ```bash
    bin/kafka-server-start.sh config/server.properties
    ```

4. Testing the configuration

    - Run a Kafka producer and consumer to test the SASL authentication.

    **Producer**

    ```bash
    bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test-topic --producer.config /path/to/server.properties
    ```

    **Consumer**

    ```bash
    bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-topic --from-beginning --consumer.config /path/to/server.properties
    ```

    - If either client isn’t properly authenticated, the operation will fail, and the broker will log an error with details that can help in diagnosing the problem.

### Kerberos

Kerberos is an authentication protocol that allows for secure communication over an insecure network. It is a widely used authentication mechanism in enterprise environments.

The key aspects of Kerberos are:

1. **Authentication**: Kerberos uses a trusted `third-party authentication server` to verify the identity of users and services. This is done through the exchange of `encrypted tickets`.

2. **Single Sign-On (SSO)**: With Kerberos, users only need to authenticate once to gain access to multiple services and applications.

3. **Mutual Authentication**: Kerberos ensures that both the client and the server `mutually` authenticate each other before establishing a secure connection.

4. **Ticket-Based Authorization**: Kerberos uses tickets, which are `time-limited cryptographic credentials`, to grant access to services. These tickets are obtained from the authentication server.

The main components in a Kerberos system are:

- **Key Distribution Center (KDC)**: The authentication server that `issues tickets` for client-server authentication.
- **Client**: The user or application that `requests access` to a service.
- **Server**: The service that the client wants to access.

    ![Kerberos](https://kerberos.org/images/krbmsg.gif)

Kerberos is commonly used in enterprise environments, such as Active Directory, to provide secure authentication and authorization across different systems and applications.
It is considered a robust and secure authentication protocol, especially in scenarios where multiple services and users need to communicate securely over an untrusted network.

### SCRAM

SCRAM `(Salted Challenge Response Authentication Mechanism)` is an authentication mechanism that is used in various protocols, including SASL (Simple Authentication and Security Layer) and XMPP (Extensible Messaging and Presence Protocol).

The key features of SCRAM are:

1. **Password-based Authentication**: SCRAM is a password-based authentication mechanism, where the client authenticates to the server using a shared secret (password).

2. **Salted Hashing**: SCRAM uses salted hashing to store and verify passwords. This helps protect against password cracking and rainbow table attacks.

3. **Challenge-Response**: SCRAM uses a challenge-response protocol, where the server challenges the client, and the client responds with a cryptographic proof of their identity.

4. **Mutual Authentication**: SCRAM provides mutual authentication, where both the client and the server authenticate each other.

5. **Resistance to Replay Attacks**: SCRAM includes nonces (unique numbers used only once) in the challenge-response exchange, which helps prevent replay attacks.

6. **Channel Binding**: SCRAM can be used with channel binding, which allows the authentication to be tied to the underlying secure transport layer (e.g., TLS/SSL).

![SCRAM Auth](https://cdn.bloghunch.com/uploads/LtJucb4325vX5cI7.webp)

SCRAM is designed to be a more secure alternative to traditional password-based authentication mechanisms, such as plaintext password transmission or the use of unsalted hashes.
It is commonly used in protocols like XMPP, LDAP, and MongoDB to provide secure authentication between clients and servers.

## What are Kafka Connectors?

Kafka connectors are pluggable components used within the Kafka Connect framework to move data between Apache Kafka and external systems, such as databases, file systems, cloud services, or search indexes. They simplify the integration process, allowing you to build robust data pipelines without custom code.

### Types of Kafka Connectors

- **Source Connectors:**
  Import data from external systems into Kafka topics [e.g., ingesting data from a database into Kafka].

- **Sink Connectors:**
  Export data from Kafka topics to external systems [e.g., sending Kafka topic data to Elasticsearch, S3, or a relational database].

  ![Kafka connector](https://camunda.com/wp-content/uploads/camunda/zeebe-images/blog/zeebe-kafka-connect/kafka-connect-from-confluent.png "Kafka Connector")

### Key Concepts

- **Connector Plugins:**
  Encapsulate the logic for connecting to a specific external system. You can use pre-built connectors or develop custom ones.

- **Tasks:**
  Units of work assigned to connectors, responsible for processing subsets of data. Multiple tasks can run in parallel for scalability.

  Tasks themselves have no state stored within them. Rather a task’s state is stored in special topics in Kafka, config.storage.topic and status.storage.topic, and managed by the associated connector. Tasks may be started, stopped, or restarted at any time to provide a resilient and scalable data pipeline.

  ![Tasks](https://docs.confluent.io/platform/current/_images/data-model-simple.png "Tasks")

- **Task rebalancing:**
  When a connector is first submitted to the cluster, the workers rebalance the full set of connectors in the cluster and their tasks so that each worker has approximately the same amount of work.

  This rebalancing procedure is also used when connectors increase or decrease the number of tasks they require, or when a connector’s configuration is changed. When a worker fails, tasks are rebalanced across the active workers.

  When a task fails, no rebalance is triggered, as a task failure is considered an exceptional case. As such, failed tasks are not restarted by the framework and should be restarted using the REST API.

  ![Task failover](https://docs.confluent.io/platform/current/_images/task-failover.png "Task Failover")

- **Workers:**
  Connectors and tasks are logical units of work and must be scheduled to execute in a process. Kafka Connect calls these processes workers.

  Workers can be run in `standalone` mode (single node) or `distributed` mode (multi-node for scalability and fault tolerance).

  - **Standalone workers**
    - Simplest mode, where a single process is responsible for executing all connectors and tasks.
    - Requires minimal configuration.
    - Convenient for getting started, during development, and in certain situations where only one process makes sense, such as collecting logs from a host.

  - **Destributed workers**
    - Multiple processes (workers) run in a cluster, allowing for horizontal scaling and fault tolerance.
    - Connectors and tasks are distributed across the workers, enabling parallel processing.
    - Provides automatic task rebalancing and failover capabilities.
    - In distributed mode, you start many worker processes using the same `group.id` and they coordinate to schedule execution of connectors and tasks across all available workers.
    - Note that all workers with the same `group.id` will be in the same connect cluster. For example, if worker A has `group.id=connect-cluster-a` and worker B has the same `group.id`, worker A and worker B will form a cluster called `connect-cluster-a`.

    ![Distributed workers](https://docs.confluent.io/platform/current/_images/worker-model-basics.png "Distributed Workers")

- **Transformations:**
  Single Message Transformations (SMTs) allow lightweight data manipulation as messages pass through Kafka Connect.

  - This can be convenient for `minor data adjustments` and `event routing`, and many transformations can be chained together in the connector configuration.

  - Accepts one record as an input and outputs a modified record.

- **Converters:**
  Handle `serialization and deserialization` of data between Kafka and external systems.

  - **AvroConverter** `io.confluent.connect.avro.AvroConverter`: use with Schema Registry
  - **ProtobufConverter** `io.confluent.connect.protobuf.ProtobufConverter`: use with Schema Registry
  - **JsonSchemaConverter** `io.confluent.connect.json.JsonSchemaConverter`: use with Schema Registry
  - **JsonConverter** `org.apache.kafka.connect.json.JsonConverter` (without Schema Registry): use with structured data
  - **StringConverter** `org.apache.kafka.connect.storage.StringConverter`: simple string format
  - **ByteArrayConverter** `org.apache.kafka.connect.converters.ByteArrayConverter`: provides a “pass-through” option that does no conversion

  Converters are decoupled from connectors themselves to allow for the reuse of converters between connectors.

  **E.X.**

  ```json
  {
    "name": "jdbc-source-connector",
    "config": {
      "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
      "tasks.max": "1",
      "connection.url": "jdbc:mysql://localhost:3306/mydb",
      "table.whitelist": "my_table",
      "mode": "incrementing",
      "incrementing.column.name": "id",
      "topic.prefix": "jdbc-",
      "key.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter"
    }
  }
  ```

  >The same converter can be used even though, for example, the JDBC source returns a ResultSet that is eventually written to HDFS as a parquet file.

  ![Converters](https://docs.confluent.io/platform/current/_images/converter-basics.png "Converters")

### Use Cases

- Streaming data from databases (like MySQL or PostgreSQL) into Kafka topics.
- Exporting Kafka topic data to data lakes, warehouses, or analytics platforms.
- Real-time data synchronization between systems.

### Benefits

- Reduces the need for custom integration code.
- Scalable and fault-tolerant architecture.
- Supports both batch and streaming data movement.
- Easily extensible with pre-built or custom connectors.

In summary, Kafka connectors are essential building blocks within Kafka Connect, enabling efficient and reliable data integration between Kafka and a wide variety of external systems.

- <https://www.redpanda.com/guides/kafka-tutorial-what-is-kafka-connect> "kafka-tutorial-what-is-kafka-connect"
- <https://www.baeldung.com/kafka-connectors> "kafka-connectors"
- <https://docs.confluent.io/platform/current/connect/index.html> "confluent-kafka-connect"
- <https://docs.snowflake.com/en/user-guide/kafka-connector-overview> "snowflake-kafka-connector-overview"
- <https://www.redpanda.com/guides/kafka-cloud-kafka-connectors> "kafka-cloud-kafka-connectors"
- <https://www.instaclustr.com/education/apache-kafka/apache-kafka-connect-the-basics-and-a-quick-tutorial> "apache-kafka-connect-the-basics-and-a-quick-tutorial"
- <https://docs.confluent.io/platform/current/connect/kafka_connectors.html> "confluent-kafka_connectors"
- <https://cloud.google.com/integration-connectors/docs/connectors/apachekafka/configure> "google-cloud-integration-connectors-apachekafka-configure"

## Important feature/configurations in Kafka

### `auto.create.topics.enable`

The `auto.create.topics.enable` configuration in Apache Kafka determines whether Kafka automatically creates topics when a producer or consumer attempts to access a non-existent topic. By default, this setting is enabled, allowing for dynamic topic creation. However, in production environments, it is often recommended to disable this feature to avoid unintentional topic creation and to maintain better control over the Kafka ecosystem.

### `delete.topic.enable`

Controls whether topics can be deleted in Kafka. By default, this setting is disabled, meaning that topics cannot be deleted once they are created. Enabling this feature allows for more flexible topic management but should be done with caution to avoid accidental data loss.

### `enable.idempotence`

Ensure that messages are produced exactly once to a Kafka topic, even in the presence of failures. When this setting is enabled, Kafka producers will automatically handle retries and deduplicate messages, providing stronger guarantees about message delivery. This feature is particularly important in scenarios where data integrity is critical.

### `cleanup.policy`

Determines how Kafka handles the retention and deletion of messages in a topic. It can be set to either `delete` or `compact`.

- **`delete`**: Messages are deleted after a specified retention period, allowing for efficient storage management.
- **`compact`**: Messages are retained based on their keys, allowing for the latest version of each key to be kept while older versions are removed. This is useful for topics that require a compacted view of the data, such as change logs or state stores.

Imagine you’re building a user profile service.

Each update event looks like: `| Key (User ID) | Value (Profile Data) |`

Over time, users update their profile many times:

```text
Day 1: User123 → Name = John
Day 2: User123 → Name = Johnny
Day 3: User123 → Name = Jonathan
```

- Without log compaction: All three events would stay in the topic.
- With log compaction: Only the latest (Name = Jonathan) is retained.

### `compression.type`

Specifies the compression algorithm used for messages in a Kafka topic. It can be set to various values, including:

- **`none`**: No compression is applied.
- **`gzip`**: Uses the GZIP compression algorithm, which provides a good balance between compression ratio and speed.
- **`snappy`**: Uses the Snappy compression algorithm, which is optimized for speed and provides lower compression ratios compared to GZIP.
- **`lz4`**: Uses the LZ4 compression algorithm, which provides high compression ratios and fast decompression speeds.
- **`zstd`**: Uses the Zstandard compression algorithm, which offers a good balance between compression ratio and speed, and is suitable for high-throughput scenarios.

### `retention.ms`

The `retention.ms` configuration in Apache Kafka determines how long messages are retained in a topic before they are eligible for deletion (default: 7 days). It is specified in milliseconds and can be set to a specific duration or to `-1` to indicate that messages should be retained indefinitely.

```bash
kafka-topics.sh --alter --topic my-topic --config retention.ms=604800000 --bootstrap-server localhost:9092
```

### `transactiona.id`

The `transactional.id` configuration in Apache Kafka is used to enable exactly-once semantics (EOS) for producers. It uniquely identifies a producer instance and allows it to participate in transactions, ensuring that messages are produced atomically and consistently.

To enable this feature, you need to set the `transactional.id` property in the producer configuration. This ID must be unique across all producer instances in the Kafka cluster.

- On a producer side.

```properties
transactional.id=my-transactional-id
```

- On a consumer side, you need to set the `isolation.level` property to `read_committed` to ensure that consumers only read messages that are part of committed transactions.

```properties
isolation.level=read_committed
```

```python
producer.init_transactions()
producer.begin_transaction()
producer.send('habit-topic', value=b'Finished Reading')
producer.send('streak-topic', value=b'Increment Streak')
producer.commit_transaction()
```

### MirrorMaker

**MirrorMaker** is a tool provided by Apache Kafka that allows you to `replicate data between Kafka clusters`. It is particularly useful for scenarios such as `disaster recovery`, `data migration`, or `creating a backup` of your Kafka data.

MirrorMaker continuously copies messages from the source to the target.

Key Features of MirrorMaker

- **Cross-Cluster Replication**: MirrorMaker can replicate data from one Kafka cluster to another, enabling you to maintain multiple copies of your data across different clusters.
- **Data Synchronization**: It ensures that data is synchronized between the source and destination clusters, allowing for real-time or near-real-time replication.
- **Fault Tolerance**: MirrorMaker can handle failures in the source or destination clusters, ensuring that data replication continues even in the event of issues.
- **Scalability**: It can be scaled horizontally by adding more MirrorMaker instances to handle larger data volumes or higher replication rates.

It’s mostly used for:

- Disaster Recovery (DR)
- Multi-region deployments (e.g., US cluster + EU cluster)
- Cloud migrations (on-prem → cloud)

You configure:

- Source cluster details
- Target cluster details
- Topics to replicate

MirrorMaker does the rest.

```bash
kafka-mirror-maker.sh --consumer.config source-cluster.properties --producer.config target-cluster.properties --whitelist "topic1,topic2"
```

### ACLs (Access Control Lists)

ACLs in Kafka are used to manage permissions for users and applications interacting with Kafka resources (topics, consumer groups, etc.). They help enforce security and ensure that only authorized entities can perform specific actions.

#### How to Create and Manage ACLs in Kafka

1. **Create ACLs**

   You can create ACLs using the `kafka-acls.sh` command-line tool.

   For example, to allow a user to read from a specific topic:

   ```bash
   kafka-acls.sh --add --allow-principal User:Alice --operation Read --topic my-topic --bootstrap-server localhost:9092
   ```

2. **List ACLs**

   To view the existing ACLs for a specific resource:

   ```bash
   kafka-acls.sh --list --topic my-topic --bootstrap-server localhost:9092
   ```

3. **Delete ACLs**

   To remove an existing ACL:

   ```bash
   kafka-acls.sh --remove --allow-principal User:Alice --operation Read --topic my-topic --bootstrap-server localhost:9092
   ```

Kafka ACLs can be based on:

- User identities (authenticated via SASL, Kerberos, etc.)
- IP addresses
- Groups

ACLs define permissions like:

- Allow or Deny
- Operation: Read, Write, Delete, Alter, etc.
- Resource: Topic, Group, Cluster

ACLs are stored internally by Kafka (or sometimes in Zookeeper, depending on mode).

## Strimzi Operator

Strimzi provides container images and operators for running Kafka on Kubernetes. These operators are designed with specialized operational knowledge to efficiently manage Kafka on Kubernetes.

Strimzi operators simplify:

- Deploying and running Kafka clusters
- Deploying and managing Kafka components
- Configuring Kafka access
- Securing Kafka access
- Upgrading Kafka
- Managing brokers
- Creating and managing topics
- Creating and managing users

### Operators

Operators are Kubernetes components that package, deploy, and manage applications by extending the Kubernetes API. They simplify administrative tasks and reduce manual intervention.

Strimzi operators automate the deployment and management of Apache Kafka components on Kubernetes. Strimzi custom resources define the deployment configuration.

The following operators manage Kafka in a Kubernetes cluster:

- **Cluster Operator**: Manages Kafka clusters and related components.
- **Entity Operator**: Comprises the Topic Operator and User Operator.
- **Topic Operator**: Creates, configures, and deletes Kafka topics.
- **User Operator**: Manages Kafka users and their authentication credentials.

Additionally, Strimzi provides Drain Cleaner, a separate tool that can be used alongside the Cluster Operator to **assist with safe pod eviction during maintenance or upgrades**.

![Strimzi Operator](https://snourian.com/wp-content/uploads/2020/10/operators-1024x799.png "Strimzi Operator")

1. Cluster Operator

    The Cluster Operator manages the clusters of the following Kafka components:
    - Kafka (including Entity Operator, Kafka Exporter, and Cruise Control)
    - Kafka Connect
    - Kafka MirrorMaker
    - Kafka Bridge

    For example, to deploy a Kafka cluster:
    - A Kafka resource with the cluster configuration is created within the Kubernetes cluster.
    - The Cluster Operator deploys a corresponding Kafka cluster, based on what is declared in the Kafka resource.

    The Cluster Operator can also deploy the following Strimzi operators through configuration of the Kafka resource:
    - `Topic Operator` to provide operator-style topic management through KafkaTopic custom resources
    - `User Operator` to provide operator-style user management through KafkaUser custom resources

    ![Cluster Operator](<https://strimzi.io/docs/operators/latest/images/cluster-operator.png> "Cluster Operator")

2. Topic Operator

    The Topic Operator manages Kafka topics and their configurations. It automates tasks such as:

    - Creating and deleting topics
    - Configuring topic settings (partitions, replication factor, etc.)
    - Managing topic ACLs (Access Control Lists)

    ```yaml
    apiVersion: kafka.strimzi.io/v1beta2
    kind: KafkaTopic
    metadata:
      name: osds-topic
      labels:
        strimzi.io/cluster: "osds-cluster"
    spec:
      partitions: 3
      replicas: 1
    ```

    The Topic Operator watches for changes to `KafkaTopic` custom resources and applies the necessary changes to the Kafka cluster.

   ![Topic Operator](<https://strimzi.io/docs/operators/latest/images/topic-operator.png> "Topic Operator")

    The Topic Operator manages Kafka topics by watching for `KafkaTopic` resources that describe Kafka topics, and ensuring that they are configured properly in the Kafka cluster.

    When a `KafkaTopic` is created, deleted, or changed, the Topic Operator performs the corresponding action on the Kafka topic.
    You can declare a `KafkaTopic` as part of your application’s `deployment` and the Topic Operator manages the Kafka topic for you.

3. User Operator

    The User Operator manages Kafka users and their authentication credentials. It automates tasks such as:
    - Creating and deleting users
    - Configuring user authentication (SASL, SSL, etc.)
    - Managing user ACLs (Access Control Lists)

    The User Operator watches for changes to `KafkaUser` custom resources and applies the necessary changes to the Kafka cluster.

    <!-- ![User Operator](<https://strimzi.io/docs/operators/latest/images/user-operator.png> "User Operator") -->

    The User Operator manages Kafka users by watching for `KafkaUser` resources that describe Kafka users, and ensuring that they are configured properly in the Kafka cluster.

    ```yaml
    apiVersion: kafka.strimzi.io/v1beta2
    kind: KafkaUser
    metadata:
      name: my-user
      labels:
        strimzi.io/cluster: "my-cluster"
    spec:
      authentication:
        type: tls
      authorization:
        acls:
          - resource:
              type: topic
              name: my-topic
            operation: Read
            principal: User:my-user
          - resource:
              type: group
              name: my-group
            operation: Read
            principal: User:my-user
    ```

    When a `KafkaUser` is created, deleted, or changed, the User Operator performs the corresponding action on the Kafka user.
    You can declare a `KafkaUser` as part of your application’s `deployment` and the User Operator manages the Kafka user for you.

4. Entity Operator

    The Entity Operator is a combination of the `Topic Operator` and `User Operator`. It provides a unified interface for managing both Kafka topics and users.

    The Entity Operator watches for changes to `KafkaTopic` and `KafkaUser` custom resources and applies the necessary changes to the Kafka cluster.

    ```yaml
    apiVersion: kafka.strimzi.io/v1beta2
    kind: EntityOperator
    metadata:
      name: entity-operator
      labels:
        strimzi.io/cluster: "my-cluster"
    spec:
      topicOperator:
        reconciliationInterval: 60s
      userOperator:
        reconciliationInterval: 60s
    ```

    <!-- ![Entity Operator](<https://strimzi.io/docs/operators/latest/images/entity-operator.png> "Entity Operator") -->

5. Drain Cleaner

    The Drain Cleaner is a tool that can be used alongside the Cluster Operator to assist with safe pod eviction during maintenance or upgrades.

## Kafka High performance Tuning

Kafka is designed to handle high throughput and low latency, but performance tuning is often necessary to achieve optimal results. Here are some key configurations and practices for tuning Kafka performance:

### 1. Broker Configuration

- **`num.network.threads`**: Increase the number of network threads to handle more concurrent connections. The default is `3`, but you can increase it based on your hardware capabilities and expected workload.
- **`num.io.threads`**: Increase the number of I/O threads to handle more disk operations. The default is `8`, but you can increase it based on your hardware capabilities and expected workload.
- **`socket.send.buffer.bytes`**: Increase the send buffer size to allow larger messages to be sent without fragmentation. The default is `102400 bytes`, but you can increase it based on your message size and network capabilities.
- **`socket.receive.buffer.bytes`**: Increase the receive buffer size to allow larger messages to be received without fragmentation. The default is `102400 bytes`, but you can increase it based on your message size and network capabilities.
- **`log.flush.interval.messages`**: Set the number of messages after which the log is flushed to disk. A lower value can improve durability but may impact performance. The default is `10000`, but you can adjust it based on your durability requirements.
- **`log.flush.interval.ms`**: Set the time interval after which the log is flushed to disk. A lower value can improve durability but may impact performance. The default is `60000 ms`, but you can adjust it based on your durability requirements.
- **`queued.max.requests`**: Increase the maximum number of requests that can be queued for processing. The default is `500`, but you can increase it based on your expected workload and hardware capabilities.
- **`replica.fetch.max.bytes`**: Increase the maximum size of messages that can be fetched by replicas. The default is `1048576 bytes`, but you can increase it based on your message size and replication requirements.

```properties
num.network.threads=5
num.io.threads=8
queued.max.requests=500
replica.fetch.max.bytes=2097152
```

### 2. Producer Configuration

- **`linger.ms`**: Set the time to wait before sending a batch of messages. A higher value can improve throughput but may increase latency. The default is `0 ms`, but you can adjust it based on your performance requirements. Delays sending messages to batch up more data.
- **`batch.size`**: Set the maximum size of a batch of messages. A larger batch size can improve throughput but may increase latency. The default is `16384 bytes`, but you can adjust it based on your message size and performance requirements.
- **`compression.type`**: Use compression to reduce the size of messages sent over the network. Options include `none`, `gzip`, `snappy`, `lz4`, and `zstd`. Compression can improve throughput and reduce network bandwidth usage.

```properties
linger.ms=100
batch.size=32768
compression.type=gzip
```

### 3. Consumer Configuration

- **`fetch.min.bytes`**: Set the minimum amount of data that the consumer will wait for before returning a response. A higher value can improve throughput but may increase latency. The default is `1 byte`, but you can adjust it based on your performance requirements.
- **`fetch.max.wait.ms`**: Set the maximum time the consumer will wait for data before returning a response. A higher value can improve throughput but may increase latency. The default is `500 ms`, but you can adjust it based on your performance requirements.
- **`max.partition.fetch.bytes`**: Set the maximum size of a single partition fetch request. A larger value can improve throughput but may increase memory usage. The default is `1048576 bytes`, but you can adjust it based on your message size and performance requirements.

```properties
fetch.min.bytes=1024
fetch.max.wait.ms=1000
max.partition.fetch.bytes=2097152
```

### 4. Topic Configuration

- **`num.partitions`**: Increase the number of partitions for a topic to improve parallelism and throughput. The default is `1`, but you can increase it based on your expected workload and hardware capabilities.
- **`segment.bytes`**: Set the maximum size of a single log segment file. A larger value can improve throughput but may increase disk usage. The default is `1073741824 bytes (1 GB)`, but you can adjust it based on your storage capabilities and performance requirements.
- **`retention.ms`**: Set the time to retain log segments before they are eligible for deletion. A longer retention period can improve durability but may increase disk usage. The default is `604800000 ms (7 days)`, but you can adjust it based on your durability requirements.
- **`min.cleanable.dirty.ratio`**: Set the minimum ratio of dirty log segments that must be cleaned up before a log segment can be deleted. A higher value can improve throughput but may increase disk usage. The default is `0.2 (20%)`, but you can adjust it based on your performance requirements.

```bash
bin/kafka-configs.sh --bootstrap-server localhost:9092 \
  --entity-type topics \
  --entity-name my-high-performance-topic \
  --alter \
  --add-config num.partitions=10,segment.bytes=1073741824,retention.ms=604800000,min.cleanable.dirty.ratio=0.2
```

## Backup of Kafka data and configurations

Backing up Apache Kafka involves safeguarding both the data stored in topics and the critical metadata that maintains cluster configuration. This includes topic data, consumer offsets, configuration settings, Access Control Lists (ACLs), and, depending on your setup, the state stored in ZooKeeper or KRaft's metadata directory.

### What Needs to Be Backed Up

- **Topic Data:** The messages stored in Kafka topics.
- **Consumer Offsets:** Tracks how much of each topic each consumer group has read.
- **Configuration Settings:** Broker, topic, and cluster configurations.
- **ACLs:** Access control information for security.
- **ZooKeeper or KRaft Metadata:** Stores cluster state, topic configurations, users, ACLs, and passwords.

### Methods for Backing Up Kafka

#### 1. File System Snapshots

- **Process:** Shut down each broker one at a time, take a snapshot of the file system where Kafka data is stored, copy the snapshot to backup storage, and then restart the broker.
- **Pros:** Simple, uses native OS tools, ensures offsets and internal topics are backed up.
- **Cons:** Requires broker downtime, risk of missing data during partition rebalancing, harder to do incremental backups.

#### 2. Copying Broker Logs

- **Process:** Use tools like `rsync` to copy the broker log directories, then compress the copy with `zip` or `gzip`.
- **Note:** This is feasible but not always recommended for live clusters due to potential inconsistencies.

#### 3. Kafka Backup Tools

- **Kafka Backup (Open Source):** A tool that backs up and restores topic data and consumer group offsets via `Kafka Connect` connectors. It supports backup/restore to/from the local file system and is designed for cold backups.
- **Commercial Solutions:** Tools like `Kannika` (commercial) and `Veeam Kasten` (for Kubernetes environments) offer more advanced, automated, and cloud-integrated backup options.
- **S3 Connectors:** Use connectors (e.g., Adobe S3 Kafka connector) to periodically export topic data to cloud storage like S3 for backup and restore.

#### 4. ZooKeeper/KRaft Metadata Backup

- **ZooKeeper:** Backup the `dataDir` directory specified in `zookeeper.properties`. This contains the cluster state, topic configs, users, ACLs, and more. Create a compressed archive of this directory for storage.
- **KRaft Mode:** Backup the entire KRaft metadata directory, which contains similar information as ZooKeeper but is used in newer Kafka deployments.

### Example Commands

**Backing up ZooKeeper data:**

```bash
tar -czvf zookeeper-backup.tar.gz /path/to/zookeeper/dataDir
```

**Backing up Kafka data using kafka-backup:** [GitHub](https://github.com/itadventurer/kafka-backup)

```bash
backup-standalone.sh --bootstrap-server localhost:9092 \
    --target-dir /path/to/backup/dir --topics 'topic1,topic2'
```

Or via Docker:

```bash
docker run -d -v /path/to/backup-dir/:/kafka-backup/ --rm \
    kafka-backup:[LATEST_TAG] \
    backup-standalone.sh --bootstrap-server kafka:9092 \
    --target-dir /kafka-backup/ --topics 'topic1,topic2'
```

### Recommendations

- **For full resilience:** Use Kafka’s replication features and consider multi-datacenter setups for high availability.
- **For disaster recovery:** Regularly backup both data and configuration/metadata, store backups offsite (e.g., S3), and test your restore procedures.
- **For configuration:** Always backup ZooKeeper or KRaft metadata directories in addition to topic data.

### Summary Table: Kafka Backup Approaches

| Method                    | What It Backs Up                  | Pros                      | Cons                           |
|---------------------------|-----------------------------------|---------------------------|--------------------------------|
| File System Snapshots     | Data logs, offsets, configs       | Simple, native tools      | Broker downtime, risk of missing partitions |
| Kafka Backup Tool         | Topic data, consumer offsets      | Incremental, cold backup  | File system only, project status |
| S3/Cloud Connectors       | Topic data                        | Automated, cloud storage  | May not include metadata   |
| ZooKeeper/KRaft Backup    | Cluster configs, ACLs, offsets    | Full config backup        | Manual steps, critical for recovery |

### Conclusion

A comprehensive Kafka backup strategy covers both topic data and all configuration/metadata. Use a combination of file system snapshots, specialized backup tools, and regular ZooKeeper/KRaft metadata backups to ensure you can recover from data loss or cluster failures.

- [1] <https://www.digitalocean.com/community/tutorials/how-to-back-up-import-and-migrate-your-apache-kafka-data-on-ubuntu-18-04>
- [2] <https://forum.confluent.io/t/backing-up-the-kafka-cluster-data/603>
- [3] <https://github.com/itadventurer/kafka-backup>
- [4] <https://www.instaclustr.com/support/documentation/kafka/kafka-cluster-operations/cluster-config-backup/>
- [5] <https://github.com/itadventurer/kafka-backup/blob/master/docs/Comparing_Kafka_Backup_Solutions.md>
- [6] <https://docs.kasten.io/8.0.0/kanister/kafka/k8s/install/>
- [7] <https://canonical.com/data/docs/kafka/iaas/h-backup>
- [8] <https://aws.amazon.com/blogs/big-data/back-up-and-restore-kafka-topic-data-using-amazon-msk-connect/>
- [9] <https://github.com/itadventurer/kafka-backup/blob/master/docs/>

## What is Kafka MirrorMaker?

Kafka MirrorMaker is a tool designed for replicating data between two or more Apache Kafka clusters. Its primary purpose is to enable seamless data movement and synchronization across clusters, which is essential for disaster recovery, data migration, geo-replication, and multi-region deployments.

MirrorMaker comes in two major versions:

- **MirrorMaker 1:** Uses a simple consumer-producer pair.
- **MirrorMaker 2 (MM2):** Built on the Kafka Connect framework, offering advanced features, scalability, and reliability.

### How Does MirrorMaker Work?

MirrorMaker operates by **consuming messages from topics in a source Kafka cluster and producing them to corresponding topics in a target Kafka cluster**. `MM2` leverages Kafka Connect, using specialized connectors to automate and manage the replication process.

### Key Components in MirrorMaker 2

- **MirrorSourceConnector:** Replicates topics, configurations, and ACLs from the source to the target cluster.
- **MirrorCheckpointConnector:** Handles consumer group offset translation, allowing consumers to switch clusters without losing their position.
- **MirrorHeartbeatConnector:** Monitors the health and connectivity between clusters.
- **MirrorSinkConnector:** Writes replicated data into the target cluster.

### Main Features of MirrorMaker 2

- **Automated Topic Management:** Detects and replicates new topics and partitions automatically.
- **Consumer Offset Synchronization:** Translates consumer offsets to enable seamless failover and migration.
- **Bidirectional and Multi-Cluster Replication:** Supports unidirectional, bidirectional, and complex topologies [e.g., hub-and-spoke, multi-region].
- **Dynamic Configuration:** Allows changes to replication rules without restarts.
- **High Availability and Scalability:** Built on Kafka Connect for distributed, fault-tolerant operation.

### Common Use Cases

- **Disaster Recovery:** Keeps a backup Kafka cluster in sync for failover in case of primary cluster failure.
- **Data Migration:** Moves data between clusters during cloud adoption or infrastructure upgrades.
- **Geo-Replication:** Ensures data is available across multiple data centers or regions.
- **Data Aggregation:** Consolidates data from multiple clusters into a central analytics cluster.
- **Data Isolation:** Selectively replicates topics to control data exposure between environments.

### Example: How MirrorMaker 2 Replicates Data

1. **Source Connector** reads messages from the source cluster.
2. **Checkpoint Connector** synchronizes consumer offsets.
3. **Heartbeat Connector** monitors replication health.
4. **Sink Connector** writes messages to the target cluster.

### Summary Table: MirrorMaker 2 Features

| Feature                        | Description                                        |
|--------------------------------|----------------------------------------------------|
| Automated Topic Detection      | Replicates new topics/partitions automatically.  |
| Offset Synchronization         | Maintains consumer position across clusters.  |
| Multi-Cluster Topologies       | Supports various replication patterns.        |
| Dynamic Configuration          | Change rules without restarts.                   |
| High Availability              | Distributed, fault-tolerant via Kafka Connect.   |

- [1] <https://www.openlogic.com/blog/kafka-mirrormaker-overview>
- [2] <https://developers.redhat.com/articles/2023/11/13/demystifying-kafka-mirrormaker-2-use-cases-and-architecture>
- [3] <https://risingwave.com/blog/complete-guide-to-kafka-mirrormaker/>
- [4] <https://www.redpanda.com/guides/kafka-alternatives-kafka-mirrormaker>
- [5] <https://www.instaclustr.com/blog/kafka-mirrormaker-2-theory/>
- [6] <https://github.com/AutoMQ/automq/wiki/Kafka-MirrorMaker-2(MM2):-Usages-&-Best-Practices>
- [7] <https://learn.microsoft.com/en-us/azure/hdinsight/kafka/kafka-mirrormaker-2-0-guide>
- [8] <https://cloud.google.com/managed-service-for-apache-kafka/docs/move-kafka-mirrormaker>
- [9] <https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-kafka-mirrormaker-2-tutorial>
- [10] <https://www.automq.com/blog/kafka-mirrormaker-2-usages-best-practices>
