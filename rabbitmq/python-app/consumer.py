import pika

def on_message_received(channel, method, properties, body):
    print(f"new message received: {body}")

connection_params = pika.ConnectionParameters("localhost")
connection = pika.BlockingConnection(connection_params)
channel = connection.channel()

channel.basic_consume(queue="letterbox", auto_ack=True, on_message_callback=on_message_received)

print("Started consuming, CTRL+C to exit")
channel.start_consuming()