import pika

connection_params = pika.ConnectionParameters("localhost")
connection = pika.BlockingConnection(connection_params)
channel = connection.channel()

channel.queue_declare(queue="letterbox")
message = "Hello world, RabbitMQ"

channel.basic_publish(exchange="", routing_key="letterbox", body=message)

print(f"sent message: {message}")

connection.close()