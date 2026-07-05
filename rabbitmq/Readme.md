# RabbitMQ

Companies are making a shift towards the adoption of microservice-based architecture for modern applications. Implementing decoupled modules within the application is necessary for smooth and uninterrupted running no matter how much volumes of data is transferred. Message brokers allow applications to communicate and decouple from each other.

## What is RabbitMQ?

RabbitMQ is an open-source message broker service provider software that is written in the Erlang programming language. It is the first one to implement the AQMP (Advanced Message Queuing Protocol).

RabbitMQ is commonly called message-oriented middleware because it acts as a medium between publish or message provide and consumer or message consumer. RabbitMQ supports many programming languages and can run on various Cloud environments and operating systems. It comes with an extended plug-in architecture to deliver support for MQ Telemetry Transport (MQTT), Streaming Text Oriented Messaging Protocol (STOMP), and other protocols.

RabbitMQ offers both Command-line tools and web-based GUI for monitoring and managing operations. It’s lightweight and easy to deploy on Cloud and premises. It’s known for scalability and high availability because it deploys distributed and federated configurations to meet business requirements.

### Basic concepts of RabbitMQ

- **Queue**: A Queue is a sequential data structure that is a medium through which messages are transferred and stored.
- **Producer or Publisher**: It is the one who sends messages to a queue.
- **Consumer**: A consumer is the one who subscribes to and receives messages from the broker and uses that message for other defined operations.
- **Broker**: It’s a message broker that provides storage space for storing data. The broker act as middleware where data is consumed or received by another application connecting with the broker.
- **Exchange**: It’s an entry point for the broker as it receives messages from the producer and routes them to the appropriate queue.
- **Channel**: It’s a lightweight connection to a broker via a shared TCP connection.

### Key Features of RabbitMQ

Some of the main features of RabbitMQ are listed below:

- **Tools and Plugins**: RabbitMQ offers many tools and plugins support for continuous integration, operational metrics, and integration to other systems.
- **Asynchronous Messaging**: RabbitMQ supports multiple messaging protocols, delivery acknowledgment options, message queuing, routes, and various exchange types.
- **Distributed Deployment**: RabbitMQ allows users to deploy queues as clusters for high throughput and availability.
