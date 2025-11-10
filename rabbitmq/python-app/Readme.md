# RabbitMQ Python app

## Python library for message queue

```bash
python -m pip install pika --upgrade
```

## Run a RabbitMQ container

```bash
docker run -d -it --rm --name some-rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:4-management
```
