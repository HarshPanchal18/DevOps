# Notes

## Kubernetes Service vs Deployment - What's the difference between a Service and a Deployment in Kubernetes?

> A deployment is responsible for keeping a set of pods running.

> A service is responsible for enabling network access to a set of pods.

We could use a deployment without a service to keep a set of identical pods running in the Kubernetes cluster. The deployment could be scaled up and down and pods could be replicated.

Each pod could be accessed individually via direct network requests (rather than abstracting them behind a service), but keeping track of this for a lot of pods is difficult.

We could also use a service without a deployment. We'd need to create each pod individually (rather than "all-at-once" like a deployment). Then our service could route network requests to those pods via selecting them based on their labels.

`Services and Deployments are different, but they work together nicely.`

## What does ClusterIP, NodePort, and LoadBalancer mean?

The type property in the Service's `spec` determines how the service is exposed to the network.

It changes where a Service is able to be accessed from.

The possible types are ClusterIP, NodePort, and LoadBalancer:

* `ClusterIP` – The default value. The service is only accessible from within the Kubernetes cluster – you can’t make requests to your Pods from outside the cluster!
* `NodePort` – This makes the service accessible on a static port on each Node in the cluster.
  * This means that the service can handle requests that originate from outside the cluster.

* `LoadBalancer` – The service becomes accessible externally through a cloud provider's load balancer functionality.
  * GCP, AWS, Azure, and OpenStack offer this functionality.
  * The cloud provider will create a load balancer, which then automatically routes requests to your Kubernetes Service.

## Daemonsets in Kubernetes

Kubernetes is a distributed system and there should be some functionality for kubernetes platform administrators to run platform-specific applications on all the nodes. For example, running a logging agent on all the Kubernetes nodes.

Here is where Daemonset comes into the picture.
Daemonset is a native Kubernetes object. As the name suggests, it is designed to run system daemons.

The DaemonSet object is designed **to ensure that a single pod runs on each worker node.** This means you cannot scale daemonset pods in a node. And for some reason, if the daemonset pod gets deleted from the node, the daemonset controller creates it again.

> If there are 500 worker nodes and you deploy a daemonset, the daemonset controller will run one pod per worker node by default. That is a total of 500 pods. However, using `nodeSelector, nodeAffinity, Taints, and Tolerations,` you can restrict the daemonset to run on specific nodes.

> For example, in a cluster of 100 worker nodes, one might have 20 worker nodes labeled GPU enabled to run batch workloads. And you should run a pod on those 20 worker nodes. In this case, you can deploy the pod as a Daemonset using a node selector. We will look at it practically later in this guide.

### Usecases

The very basic use case of DaemonSet is in the cluster itself. If you look at the Kubernetes architecture, the kube-proxy component runs a daemonset.

1. Cluster Log Collection: Running a log collector on every node to centralize Kubernetes logging data. Eg:   fluentd , logstash, fluentbit

2. Cluster Monitoring: Deploy monitoring agents, such as Prometheus Node Exporter, on every node in the cluster to collect and expose node-level metrics. This way prometheus gets all the required worker node metrics.

3. Security and Compliance: Running CIS Benchmarks on every node using tools like kube-bench. Also deploy security agents, such as intrusion detection systems or vulnerability scanners, on specific nodes that require additional security measures. For example, nodes that handle PCI, and PII-compliant data.

4. Storage Provisioning: Running a storage plugin on every node to provide a shared storage system to the entire cluster.

5. Network Management: Running a network plugin or firewall on every node to ensure consistent network policy enforcement. For example, the Calico CNI plugin runs as Daemonset on all the nodes.

* According to requirements, we can deploy multiple DaemonSet for one kind of daemon, using a variety of flags or memory and CPU requests for various hardware types

```yaml
apiVersion: v1
kind: DaemonSet

metadata:
  name: daemon-pod
  namespace: logging
  labels:
    app: pod-logging

spec:
  selector:
    matchLabels:
      name: fluentd

  template:
    metadata:
      labels:
        name: fluentd

    spec:
      containers:
        - name: fluentd-elasticsearch
          image: quay.io/fluentd_elasticsearch/fluentd:v2.5.2

          resources:
            limits:
              memory: 200Mi
            requests:
              cpu: 100m
              memory: 200Mi

          volumeMounts:
          - name: varlog
            mountPath: /var/log

        terminationGracePeriodSeconds: 30
        volumes:
        - name: varlog
          hostPath:
            path: /var/log
```
