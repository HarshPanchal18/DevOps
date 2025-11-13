# Logging with EFK (ElasticSearch, FluentD, Kibana) stack

- Create a namespace `logging`.

```bash
kubectl create ns logging
```

- Create service account and role binding role for `logging` namespace.

```bash
kubectl apply -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/refs/heads/master/fluent-bit-service-account.yaml

kubectl apply -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/refs/heads/master/fluent-bit-role.yaml

kubectl apply -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/refs/heads/master/fluent-bit-role-binding.yaml
```

- Create a configMap which is essential for parsing and indexing logs. `@adityajosi12`

```bash
kubectl apply -f https://raw.githubusercontent.com/adityajoshi12/distributed-logging/refs/heads/main/fluentbit/fluentbit-cm.yaml
```

- Add the Elastic Helm charts repo.

```bash
helm repo add elastic https://helm.elastic.co
```

- Install Kibana.

```bash
helm install kibana elastic/kibana
```

## Method 2

- Apply `es-svc.yml`.
- Apply `es-sts.yml`.

- Verify the deployment.

```bash
kubectl port-forward es-cluster-0 9200:9200
```

- Check the health of the Elasticsearch cluster.

```bash
curl http://localhost:9200/_cluster/health/?pretty
```

- Apply `kibana-deployment.yml`.

- Verify Kibana deployment.

```bash
kubectl port-forward <kibana-pod-name> 5601:5601
```

```bash
curl http://localhost:5601/app/kibana
```

- Apply `fluentd-role.yml`.
- Apply `fluentd-sa.yml`.
- Apply `fluentd-rb.yml`.
- Apply `fluentd-ds.yml`.
- Verify the deployment via running `test-pod.yml`.
