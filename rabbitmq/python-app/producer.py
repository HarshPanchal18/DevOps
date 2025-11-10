import pika

connection_params = pika.ConnectionParameters("localhost")
connection = pika.BlockingConnection(connection_params)
channel = connection.channel()

# Exchange key
queue_key = "letterbox"

channel.queue_declare(queue=queue_key)

# Message to send inside a queue
message = "Hello world, RabbitMQ"

# Publish to the channel along with message
channel.basic_publish(exchange="", routing_key=queue_key, body=message)

print(f"sent message: {message}")

# Shutdown queue connection
connection.close()