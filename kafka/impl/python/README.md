# Utilising Kafka in Python

## A starter guide to using Kafka with Python

1. Install the Kafka Python library:

   ```bash
   pip install kafka-python
   ```

2. Create a kafka topic

    ```python
    from kafka.admin import KafkaAdminClient, NewTopic
    admin_client = KafkaAdminClient(bootstrap_servers='localhost:9092')
    topic = NewTopic(name='test-topic', num_partitions=1, replication_factor=1)
    admin_client.create_topics(new_topics=[topic], validate_only=False)
    ```

3. Create a Kafka producer:

   ```python
   from kafka import KafkaProducer

   producer = KafkaProducer(bootstrap_servers='localhost:9092')
   ```

4. Send messages to a Kafka topic:

   ```python
   producer.send('test-topic', b'Hello, Kafka!')
   ```

5. Create a Kafka consumer:

   ```python
   from kafka import KafkaConsumer

   consumer = KafkaConsumer('test-topic', bootstrap_servers='localhost:9092')
   ```

6. Read messages from a Kafka topic:

   ```python
   for message in consumer:
       print(message.value)
   ```

## Additional Features

1. Handle message deserialization (if needed):

   ```python
   from kafka import KafkaConsumer
   from kafka.errors import DeserializationError

   consumer = KafkaConsumer('test-topic', bootstrap_servers='localhost:9092')

   for message in consumer:
       try:
           value = message.value.decode('utf-8')
           print(value)
       except (UnicodeDecodeError, DeserializationError):
           print("Error deserializing message")
   ```

2. Configure consumer group and offsets:

   ```python
   from kafka import KafkaConsumer

   consumer = KafkaConsumer('test-topic', bootstrap_servers='localhost:9092', group_id='my-group')
   ```

3. Commit offsets manually (if needed):

   ```python
   from kafka import KafkaConsumer
   from kafka.errors import CommitFailedError
   consumer = KafkaConsumer('test-topic', bootstrap_servers='localhost:9092', group_id='my-group')
   for message in consumer:
       print(message.value)
       try:
           consumer.commit()
       except CommitFailedError:
           print("Failed to commit offset")
   ```

4. Handle consumer rebalance:

   ```python
   from kafka import KafkaConsumer
   from kafka import TopicPartition

   consumer = KafkaConsumer('test-topic', bootstrap_servers='localhost:9092', group_id='my-group')
   for message in consumer:
       print(message.value)
       try:
           consumer.commit()
       except CommitFailedError:
           print("Failed to commit offset")
   ```

5. Use asynchronous producer for better performance:

    ```python
    from kafka import KafkaProducer
    import json

    producer = KafkaProducer(bootstrap_servers='localhost:9092',
                             value_serializer=lambda v: json.dumps(v).encode('utf-8'))

    producer.send('test-topic', {'key': 'value'})
    producer.flush()
    ```

6. Handle producer acknowledgments:

    ```python
    from kafka import KafkaProducer
    from kafka.errors import KafkaError
    producer = KafkaProducer(bootstrap_servers='localhost:9092')
    future = producer.send('test-topic', b'Hello, Kafka!')
    try:
        record_metadata = future.get(timeout=10)
        print(f"Message sent to {record_metadata.topic} partition {record_metadata.partition} at offset {record_metadata.offset}")
    except KafkaError as e:
        print(f"Failed to send message: {e}")
    ```
