import pika

connection = pika.BlockingConnection(pika.ConnectionParameters(host='localhost'))
channel = connection.channel()

channel.exchange_declare(exchange="logs",exchange_type='fanout')

result = channel.queue_declare(queue="", exclusive=True)
queue_name = result.method.queue

channel.queue_bind(queue="",exchange="logs")

print("* waiting for logs. CTRL + C to exit")

def callback(channel, method, properties, body):
    print(f"[x] {body}")

channel.basic_consume(queue=queue_name,on_message_callback=callback, auto_ack=True)
channel.start_consuming()