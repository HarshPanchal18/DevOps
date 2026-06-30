import pika

# Establish the connection
connection = pika.BlockingConnection(pika.ConnectionParameters("localhost"))
channel = connection.channel()

# Declare a queue on 'rpcq'
channel.queue_declare(queue="rpcq")

# Method to calculate fibonacci
def fibonacci(n: int):
    if n == 0 or n == 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

# Declare a callback
def on_request(chan, method, props, body) -> None:
    n = int(body)

    print(f"[.] fibonacci({n})")
    response = fibonacci(n)

    # Publish to the given channel
    chan.basic_publish(
        exchange = "",
        routing_key = props.reply_to,
        properties = pika.BasicProperties(correlation_id = props.correlation_id),
        body = str(response)
    )

    chan.basic_ack(delivery_tag = method.delivery_tag)

channel.basic_qos(prefetch_count = 1)

# Consume message on given 'rpcq'
channel.basic_consume(queue = "rpcq", on_message_callback = on_request)

print("[x] Awaiting RPC requests")

# Start processing message until all consumers are canceled
channel.start_consuming()