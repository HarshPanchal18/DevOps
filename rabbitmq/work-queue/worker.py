import time, pika

# Establish a connection, Provide Host IP/Name if queue is out of local
connection = pika.BlockingConnection(pika.ConnectionParameters("localhost"))
channel = connection.channel()

def callback(ch, method, properties, body):
    print(f" [x] Received {body.decode()}")
    time.sleep(body.count(b'.'))
    print(" [x] Done")

queue_key = "letterbox"

channel.queue_declare(queue=queue_key)
channel.basic_consume(queue=queue_key, auto_ack=True, on_message_callback=callback)

print(f"Started consuming, CTRL + C to exit")

channel.start_consuming()