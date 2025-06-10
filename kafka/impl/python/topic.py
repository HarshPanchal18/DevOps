from kafka.admin import KafkaAdminClient, NewTopic

admin_client = KafkaAdminClient(bootstrap_servers='localhost:9092')

topic = NewTopic(name='test-topic', num_partitions=1, replication_factor=1)

admin_client.create_topics(new_topics=[topic], validate_only=False)

print(f"Topic '{topic.name}' created successfully.")

admin_client.close()  # Close the admin client after use