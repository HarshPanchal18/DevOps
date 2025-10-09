# Steps

## Start consuming from the topic

```bash
kubectl -n myproject run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.46.0-kafka-3.9.0 \
    --rm=true \
    --restart=Never -- \
    bin/kafka-console-consumer.sh \
    --bootstrap-server kafka-data-kafka-bootstrap:9092 \
    --topic mytopic
```

## Modify the file in the container to produce a new message

```bash
kubectl exec -n myproject kafka-data-connect-cluster-connect-0 -- /bin/sh -c 'echo "Newline of data" >> /tmp/test.txt'
kubectl exec -n myproject kafka-data-connect-cluster-connect-0 -- /bin/sh -c 'echo "Newline of data" >> /tmp/test.txt'
kubectl exec -n myproject kafka-data-connect-cluster-connect-0 -- /bin/sh -c 'echo "Newline of data|latest" >> /tmp/test.txt'
```

## Switch to the consumer terminal to see updated messages

```json
{"schema":{"type":"string","optional":false},"payload":"Newline of data"}
{"schema":{"type":"string","optional":false},"payload":"Newline of data"}
{"schema":{"type":"string","optional":false},"payload":"Newline of data|latest"}
```
