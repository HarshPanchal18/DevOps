from kafka import KafkaProducer

producer = KafkaProducer(bootstrap_servers='localhost:9092')

print("Kafka producer started, sending messages...")

# for _ in range(10):
future = producer.send('test-topic', b'Hello, Kafka!')
result = future.get(timeout=10)  # Wait for the send to complete

print(f"Message sent to topic: {result.topic}, partition: {result.partition}, offset: {result.offset}")

producer.flush()  # Ensure all messages are sent before closing