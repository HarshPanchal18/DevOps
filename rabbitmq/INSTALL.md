# RabbitMQ Installation Guide on Kubernetes cluster

[Reference](https://www.rabbitmq.com/kubernetes/operator/install-operator)

Installation of RabbitMQ on a Kubernetes cluster can be done using the RabbitMQ Operator. This guide provides steps to install the operator and deploy RabbitMQ instances.

## Pre-requisites

* A Kubernetes cluster (version 1.16 or later).
* `kubectl` command-line tool configured to communicate with your cluster.
* Helm 3 installed on your local machine.
* PV provisioner supported by the Kubernetes cluster (e.g., NFS, AWS EBS, GCE PD).

## Installation using helm charts

* Create a namespace for RabbitMQ:

```bash
kubectl create namespace rabbit-system
```

* Add the Bitnami repository and install the RabbitMQ Cluster Operator:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install rabbit-op --namespace rabbit-system --create-namespace bitnami/rabbitmq-cluster-operator
```

## Using RabbitMQ Operators

* [Operators](https://www.rabbitmq.com/kubernetes/operator/using-operator#creds)

## Teardown

To uninstall the RabbitMQ Operator and remove the namespace, run the following commands:

```bash
helm uninstall rabbit-op -n rabbit-system
kubectl delete namespace rabbit-system
```
