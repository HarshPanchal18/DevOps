import sys, pika

connection = pika.BlockingConnection(pika.ConnectionParameters("localhost"))
channel = connection.channel()

queue_key = "letterbox"
message = ' '.join(sys.argv[1:]) or "Hello World!"

channel.queue_declare(queue=queue_key)

channel.basic_publish(exchange='',
                      routing_key=queue_key,
                      body=message)

print(f" [x] Sent {message}")

channel.close()