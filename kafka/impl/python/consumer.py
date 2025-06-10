from kafka import KafkaConsumer

consumer = KafkaConsumer(
    'test-topic',
    bootstrap_servers='34.173.241.157:30940',
    # group_id='test-group'
)

print("Kafka consumer started, waiting for messages...")

for message in consumer:
    print(f"Received message: {message.value.decode('utf-8')} from topic: {message.topic}")
    # This code creates a Kafka consumer that listens to the 'test-topic' topic