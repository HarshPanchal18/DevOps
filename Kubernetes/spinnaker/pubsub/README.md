# Pub/Sub

## Requirements

* GCP project created
* Kubernetes cluster created, halyard-spinnaker is deployed in cluster.

### Steps

* Create PubSub topic and subscription:

```terminal
gcloud pubsub topic create topic-spin
gcloud pubsub subscription create spin-sub topic-spin
```

* Create and configure service account

```terminal
gcloud iam service-accounts create spinnaker-sa --display-name "Spinnaker PubSub"
```

* Assign subscriber role.

```terminal
gcloud projects add-iam-policy-binding PROJECT-ID \
    --member serviceAccount:spinnaker-sa@PROJECT-ID.iam.gserviceaccount.com \
    --role roles/pubsub.subscriber
```

* Generate a json key for the service account and keep it.

```terminal
gcloud iam service-accounts create spinnaker-key.json \
    --iam-account spinnaker-sa@PROJECT-ID.iam.gserviceaccount.com
```

* Create Kubernetes secret key from spinnaker-key.json file.

```bash
kubectl create secret generic pub-sub-key --from-file=spinnaker-key.json
```

* Verify the secret key

```bash
kubectl get secrets
```

* Modify the `halyard.yml` as follow (Create /var/gcp path & bound secret-key):

```yaml
...
...
    spec:
      containers:
        ...
        ...
          volumeMounts:
            - mountPath: /home/spinnaker/.hal
              name: hal-vol
            - mountPath: /home/spinnaker/.kube
              name: kube-vol

            - mountPath: /var/gcp/
              name: pub-sub-vol

      initContainers:
        - command:
            - sh
            - "-c"
            - >-
              mkdir -p /home/spinnaker/.hal && chown -R 1000:1000
              /home/spinnaker/.hal && mkdir -p /var/gcp
          image: busybox
          imagePullPolicy: Always
          name: update-permission-crt
          volumeMounts:
            - mountPath: /opt/spin
              name: blank-vol
            - mountPath: /home/spinnaker/.hal
              name: hal-vol
            - mountPath: /var/gcp/
              name: pub-sub-vol
      ...
      ...
      ...
      volumes:
        - hostPath:
            path: /var/data/spinnaker/
            type: ""
          name: hal-vol
        - emptyDir: {}
          name: blank-vol
        - hostPath:
            path: /root/.kube/
            type: ""
          name: kube-vol

        - name: pub-sub-vol
          secret:
            secretName: pub-sub-key
```

* Re-apply the above yaml file.
* Verify the pod is running

### Configure spinnaker for PubSub

* Get into the halyard-pod.
* Enable PubSub

```bash
hal config pubsub google enable
```

* Add PubSub subscription.

```bash
hal config pubsub google subscription add my-topic \
    --subscription-name my-sub \
    --json-path /var/gcp/pubsub-key.json \
    --project <PROJECT-ID> \
    --message-format CUSTOM
```

* Deploy the changes

```bash
hal deploy apply
```

* Check running pods.

```bash
kubectl get pods -n spinnaker
```

* Send message through GCP terminal.

```bash
gcloud pubsub topics publish TOPIC-NAME --message '{"name":"harsh"}'
```

#### _OR_

* Send from GCP console.

>PubSub -> Topics -> Select Topic -> Message Tab -> Publish Message

## Troubleshooting

* Verify Secrets in Kubernetes

```bash
kubectl get secrets
```

* List files of pod.

```bash
kubectl exec -it <HALYARD_POD_NAME> -- ls /var/gcp
```

* Check Spinnaker Logs

```bash
kubectl logs -f deployment/spinnaker-gate -n spinnaker
```

* If the pipeline is not triggered, ensure:
  * The correct topic and subscription are being used.
  * The service account has proper permissions.
  * The Halyard configuration is correct.
