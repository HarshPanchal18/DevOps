# ElasticSearch, Logstash, Kibana (ELK) stack

Add elastic repo:

```bash
helm repo add elastic https://helm.elastic.co
```

Search for charts:

```bash
helm search repo elastic
```

## Configuration

```bash
helm show values elastic/filebeat > filebeat/values.yaml
helm show values elastic/logstash > logstash/values.yaml
helm show values elastic/elasticsearch > elastic/values.yaml
```

Changes inside **`filebeat/values.yaml`**

```yaml
daemonset:
    filebeatConfig:
        filebeat.yml: |
            filebeat.inputs:
            - type: container
                paths:
                - /var/log/containers/*.log
                processors:
                - add_kubernetes_metadata:
                    host: ${NODE_NAME}
                    matchers:
                    - logs_path:
                        logs_path: "/var/log/containers/"

            # output.elasticsearch:
            #   host: '${NODE_NAME}'
            #   hosts: '["https://${ELASTICSEARCH_HOSTS:elasticsearch-master:9200}"]'
            #   username: '${ELASTICSEARCH_USERNAME}'
            #   password: '${ELASTICSEARCH_PASSWORD}'
            #   protocol: https
            #   ssl.certificate_authorities: ["/usr/share/filebeat/certs/ca.crt"]

            output.logstash:
                host: ["logstash-logstash:5044"]
```

Changes inside **`logstash/values.yaml`**

```yaml
extraEnvs:
  - name: ELASTICSEARCH_USERNAME
    valueFrom:
      secretKeyRef:
        name: elasticsearch-master-credentials
        key: username
  - name: ELASTICSEARCH_PASSWORD
    valueFrom:
      secretKeyRef:
        name: elasticsearch-master-credentials
        key: password
# ...
logstashPipeline:
  logstash.conf: |
    input {
      beats {
        port=>5044
      }
    }
    output {
      elasticsearch {
        hosts=> "https://elasticsearch-master:9200"
        cacert=> "/usr/share/logstash/config/elasticsearch-master-certs/ca.crt"
        user => '${ELASTICSEARCH_USERNAME}'
        password => '${ELASTICSEARCH_PASSWORD}'
      }
    }
# ...
secretMounts:
  - name: ""
    serviceAccountName: "elasticsearch-master"
    path: "/usr/share/logstash/config/elasticsearch-master-certs"
# ...
service:
    annotations: {}
    type: ClusterIP
    loadBalancerIP: ""
    ports:
        - name: beats
          port: 5044
          protocol: TCP
          targetPort: 5044
        - name: http
          port: 8080
          protocol: TCP
          targetPort: 8080
```

Changes inside **`elastic/values.yaml`**

```yaml
replicas: 1
```

Changes inside **`kibana/values.yaml`**

```yaml
service:
    type: NodePort
```

Install via these `values.yaml`

```bash
helm install elastic elastic/elasticsearch -f elastic/values.yaml -n logging
helm install elastic elastic/filebeat -f filebeat/values.yaml -n logging
helm install elastic elastic/logstash -f logstash/values.yaml -n logging
helm install elastic elastic/kibana -f kibana/values.yaml -n logging
```

Make `kibana-kibana` service of type nodePort to access dashboard.

Get kibana dashboard credentials:

```bash
kubectl get secrets -n logging elasticsearch-master-credentials -o jsonpath={".data.username"} | base64 -d
kubectl get secrets -n logging elasticsearch-master-credentials -o jsonpath={".data.password"} | base64 -d
```

## CRD Operator based

Go to [quickstart](https://www.elastic.co/docs/deploy-manage/deploy/cloud-on-k8s/elasticsearch-deployment-quickstart)

Install Elastic's CRD:

```bash
kubectl create -f https://download.elastic.co/downloads/eck/3.2.0/crds.yaml
```

Install elastic-operator:

```bash
kubectl apply -f https://download.elastic.co/downloads/eck/3.2.0/operator.yaml
```

Install Elastic Search: [Ref](https://www.elastic.co/docs/deploy-manage/deploy/cloud-on-k8s/elasticsearch-deployment-quickstart)

```bash
kubectl apply -f elastic/elastic.yml
```

Install Kibana: [Ref](https://www.elastic.co/docs/deploy-manage/deploy/cloud-on-k8s/kibana-instance-quickstart)

```bash
kubectl apply -f kibana/kibana.yml
```

Monitor the operator’s setup by watching the logs:

```bash
kubectl -n elastic-system logs -f statefulset.apps/elastic-operator
```

When the operator is ready to use, it will report as Running

```bash
$ kubectl get -n elastic-system pods
NAME                 READY   STATUS    RESTARTS   AGE
elastic-operator-0   1/1     Running   0          1m
```

Install Kibana: [Doc](https://www.elastic.co/docs/deploy-manage/deploy/cloud-on-k8s/logstash)

```bash
kubectl apply -f logstash/logstash.yml
```

```bash
# Fix disk watermarks (no auth needed now)
kubectl exec -it elasticsearch-master-0 -- \
curl -X PUT http://localhost:9200/_cluster/settings \
-H 'Content-Type: application/json' \
-d '{
  "transient": {
    "cluster.routing.allocation.disk.watermark.low": "92%",
    "cluster.routing.allocation.disk.watermark.high": "95%",
    "cluster.routing.allocation.disk.watermark.flood_stage": "97%"
  }
}'
```
