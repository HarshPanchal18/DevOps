import pika
import uuid

class fibonacciRpcClient(object):
    def __init__(self) -> None:
        self.connection = pika.BlockingConnection(pika.ConnectionParameters("localhost"))
        self.channel = self.connection.channel()

        # Declare a queue, create if not
        result = self.channel.queue_declare(queue = "", exclusive = True)

        self.callback_queue = result.method.queue
        self.channel.basic_consume(
            queue = self.callback_queue,
            on_message_callback = self.on_response,
            auto_ack = True
        )

        self.response = None
        self.corr_id = None

    def on_response(self, channel, method, props, body) -> None:
        if self.corr_id == props.correlation_id:
            self.response = body

    def call(self, n) -> int:
        self.response = None
        self.corr_id = str(uuid.uuid4())
        self.channel.basic_publish(
            exchange = "",
            routing_key = "rpcq",
            properties = pika.BasicProperties(
                reply_to = self.callback_queue,
                correlation_id = self.corr_id
            ),
            body = str(n)
        )

        while self.response is None:
            # Will make sure that data events are processed.
            # Dispatches timer and channel callbacks if not called from the scope of BlockingConnection or BlockingChannel callback.
            self.connection.process_data_events(time_limit = None)

        return int(self.response)

fibonacciRpc = fibonacciRpcClient()

print(" [x] Requesting fibonacci(20)")
response = fibonacciRpc.call(20)
print(f" [.] Got {response}")