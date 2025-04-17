# Notes

## What is Kubernetes?

▪️ Kubernetes is an open-source container orchestration platform designed to automate deploying, scaling and managing containerized applications.

▪️ It provides a framework to run distributed systems resiliently.

▪️ Kubernetes uses a declarative approach to configuration.

▪️ Users define the desired state of their applications and infrastructure, and Kubernetes continuously works to maintain that state.

=> This is a key principle that underpins much of Kubernetes' functionality.

### Components of Kubernetes -

* `[ Pods ]` - Basic scheduling unit that holds one or more containers.

* `[ Nodes ]` - Machines (physical or virtual) in the cluster where pods are scheduled.

* `[ Cluster ]` - Collection of nodes and associated resources.

* `[ Kubelet ]` - An agent running on each node, responsible for managing the node and its containers.

* `[ Kubernetes Controller Manager ]` Manages controllers to regulate the state of the system.

* `[ Kube Proxy ]` - Maintains network rules to allow communication between pods and external traffic. (kind of Midiater firewall)

* `[ etcd ]` - Consistent and highly-available key-value store used for all cluster data.

* `[ API Server ]` - Serves the Kubernetes API and is the primary entry point for administrative tasks.

* `[ Scheduler ]` - Assigns pods to nodes based on resource requirements and other constraints.

* `[ Controller ]` - Maintains the desired state of the system, such as ensuring the correct number of replicas for a particular application.

* `[ Service ]` - Provides a consistent way to access a set of pods.

* `[ Namespace ]` - A way to divide cluster resources between multiple users.

* `[ Volumes ]` - Kubernetes supports various types of storage volumes, providing data persistence for pods.

* `[ Secrets and ConfigMaps ]` - Mechanisms to manage sensitive information and configuration data separately from application code.

* `[ Deployment ]` - A higher-level resource that manages updates to applications by handling the deployment and scaling of pods.

* `[ StatefulSets ]` - Manages stateful applications, ensuring stable network identities and persistent storage for pods.

* `[ DaemonSets ]` - Ensures that specific pods run on all (or specific) nodes for cluster-wide tasks like logging or monitoring.

* `[ Jobs and CronJobs ]` - Run short-lived or scheduled tasks within the cluster.

* `[ Ingress ]` - Manages external access to services, typically HTTP.

* `[ Network Policies ]` - Define how groups of pods can communicate with each other and other network endpoints.

* `[ Horizontal Pod Autoscaler ]` Automatically adjusts the number of replica pods to handle varying load.

* `[ Vertical Pod Autoscaler ]` - Adjusts the resources allocated to individual pods based on their usage.

* `[ Operators ]` - A way to package, deploy, and manage applications using Kubernetes APIs and controllers.

* `[ Kubectl ]` - The command-line interface to interact with Kubernetes clusters.

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

## Keys and certificates

* Keys and certificates are used in Kubernetes (and other systems) for **authentication**, **encryption**, and **authorization**.

### **Keys**

* **Private Key (`harsh.key`)**:

  * A private key is a secret key used to prove the identity of a user or system.
  * It is used to sign data (e.g., certificate signing requests) and establish secure communication.
  * It must be kept confidential and never shared.

### **Certificates**

* **Certificate (`harsh.crt`)**:
  * A certificate is a public document that binds a public key to an identity (e.g., a user or system).
  * It is issued by a trusted Certificate Authority (CA) and is used to verify the identity of the key owner.
  * In Kubernetes, certificates are used to authenticate users, nodes, or components.

### **Purpose in Kubernetes**

1. **Authentication**:
   * Certificates are used to authenticate users or components (e.g., kubelets, API servers) in the cluster.
   * The `CN` (Common Name) in the certificate identifies the user, and the `O` (Organization) specifies the group.

2. **Encryption**:
   * Certificates enable secure communication between Kubernetes components (e.g., kube-apiserver and kubelet) using TLS (Transport Layer Security).

3. **Authorization**:
   * Certificates can be tied to RBAC (Role-Based Access Control) policies to define what actions a user or component is allowed to perform in the cluster.

## RBAC Authorization

* `Role-based access control (RBAC)` is a method of regulating access to computer or network resources based on the roles of individual users within your organization.

* RBAC authorization uses the `rbac.authorization.k8s.io` API group to drive authorization decisions, allowing you to dynamically configure policies through the Kubernetes API.

* The RBAC API declares four kinds of Kubernetes object: `Role`, `ClusterRole`, `RoleBinding` and `ClusterRoleBinding`.

> An `RBAC Role` or `ClusterRole` contains rules that represent a set of permissions. Permissions are purely additive (there are no "deny" rules).

> A Role always sets permissions within a particular namespace; *when you create a Role, you have to specify the namespace it belongs in.*

> ClusterRole, by contrast, is `a non-namespaced resource`. The resources have different names (Role and ClusterRole) because a Kubernetes object always has to be either namespaced or not namespaced; it can't be both.

* ClusterRoles have several uses. You can use a ClusterRole to:

  1. define permissions on namespaced resources and be granted access within individual namespace(s)
  2. define permissions on namespaced resources and be granted access across all namespaces
  3. define permissions on cluster-scoped resources

If you want to define a role within a namespace, use a Role; if you want to define a role cluster-wide, use a ClusterRole.

* ClusterRole - A ClusterRole can be used to grant the same permissions as a Role. Because ClusterRoles are `cluster-scoped`, you can also use them to grant access to:

  * cluster-scoped resources (like nodes)

  * non-resource endpoints (like /healthz)

  * namespaced resources (like Pods), across all namespaces

* For example: you can use a ClusterRole to allow a particular user to run `kubectl get pods --all-namespaces`

* To grant read access to secrets in any particular namespace, or across all namespaces (depending on how it is bound):

```yaml
# access/simple-clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

### Steps to implement RBAC

1. Generate SSL certificate and private key (2048 bit long).

```bash
openssl genrsa -out harsh.key 2048
```

2. Create certificate signing request for the user with above key.

* The private key (`harsh.key`) and certificate signing request (`harsh.csr`) are generated for the user `harsh`.

```bash
openssl req -new \
        -key harsh.key \
        -out harsh.csr \
        -subj "/CN=harsh/O=dev/O=example.org"
```

* The `CN=harsh` specifies the username, and `O=dev` and `O=example.org` specify the groups, which can be used for RBAC rules.

3. Authorize the certificate signing request - CSR with minikube.

```bash
sudo openssl x509 -req \
            -CA /etc/kubernetes/pki/ca.crt \
            -CAkey  /etc/kubernetes/pki/ca.key \
            -CAcreateserial \
            -days 730 \
            -in harsh.csr \
            -out harsh.crt
```

* **Command breakdown**

* The certificate (`harsh.crt`) is signed by `Minikube's CA`, allowing `harsh` to authenticate with the Kubernetes cluster.

> `x509` is a standard format for public key certificates.
> `-req` indicates that the input is a `CSR - Certificate Signing Request`.
> `-CA /etc/kubernetes/pki/ca.crt` specifies the CA certificate (ca.crt) to use for signing the certificate. Same for a Certificate key.
> `CAcreateserial` - Automatically generates a serial number file (ca.srl) for the certificate if it doesn't already exist. This ensures that each certificate signed by the CA has a unique serial number.
> `-days 730` specifies the validity period of the certificate in days (730 days = 2 years).
> `-in harsh.csr` specifies the input CSR file (harsh.csr) that contains the public key and identity information for the certificate.
> `-out harsh.crt` specifies the output file (harsh.crt) where the signed certificate will be saved.

This command is typically used to create a user or component certificate for Kubernetes authentication. The signed certificate `(harsh.crt)` can then be used with the corresponding private key `(harsh.key)` to securely interact with the Kubernetes API.

4. Add user to the kubernetes cluster.

```bash
kubectl config set-credentials harsh --client-certificate=harsh.crt --client-key=harsh.key
```

5. Create a context.

```bash
kubectl config set-context harsh-k8s --cluster=kubernetes --user=harsh --namespace=default
```

6. Verify context.

```bash
kubectl config get-contexts
```

* To switch the context.

```bash
kubectl config use-context harsh-k8s
```

7. Apply the following .yaml to create a new role.

* An example Role in the "default" namespace that can be used to grant read access to pods:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

* Verify the created role.

```bash
kubectl get roles
```

8. Now we should connect these both so the user can have these permissions (RoleBinding).

> Role[What Can|Cannot access] + Subject [User|Group|ServiceAccount] = RoleBinding

* Apply the `role.yml` and `role-binding.yml` files from `rbac` directory.

9. Verify the changes via changing contexts alternatively.

### ClusterRole and ClusterRoleBinding

1. Apply the `cluster-role.yml` and `cluster-role-binding.yml` files from `rbac` directory.

### Service Account

* To create new service account,

```bash
kubectl create sa test-sa
```

* To verify that you have an access of a resource:

```bash
kubectl auth can-i create pods # If current context can create pods.
```

```bash
kubectl auth can-i create pods --as="system:serviceaccount:default:test-sa" # If test-sa service account can create pods inside "default" namespace.
kubectl auth can-i get pods --as="system:serviceaccount:default:test-sa" # If test-sa service account can get pods inside "default" namespace.
```

## Autoscaling in Kubernetes

Autoscaling in Kubernetes is a powerful feature that allows applications to dynamically adjust their resource usage based on demand.

It ensures that workloads can scale up during periods of high traffic and scale down during low usage, optimizing resource utilization and reducing costs.

* Kubernetes provides multiple types of autoscaling mechanisms:

### 1. **Horizontal Pod Autoscaler (HPA)**: Automatically adjusts the number of pod replicas in a deployment or replica set based on CPU, memory, or custom metrics

![Horizontal Pod Scaling](yml-templates/auto-scaling/hz-pod-scaling.png)

* A formula to calculate the number of pods: `d = ceil [ a * ( c / t )]`

> where,

* `d` = desired number of replicas

* `a` = actual number of replicas

* `c` = current value of the matric

* `t` = target value

#### An Example of CPU usage

```math
d = ceil[2 * (90 / 70)] = ceil[2 * 1.28] = ceil[2.57] = 3 replicas
```

where,

* 90 is current value of the cpu.
* 70 is a target value(max. limit).
* 2 is an actual number of replicas right now.

#### An Example of Memory usage

```math
d = ceil[2 * (1000 / 500)] = ceil[2 * 2] = 4 replicas
```

where,

* 1000 is current value of the memory.
* 500 is a target value(max. limit).
* 2 is an actual number of replicas right now.

* Get the metrics for the replicas via

```bash
kubectl top pods
```

* Get autoscaling metrics

```bash
kubectl get hpa
```

* [WRK](https://github.com/wg/wrk) - A HTTP benchmarking tool

### 2. **Vertical Pod Autoscaler (VPA)**: Dynamically adjusts the resource requests and limits (CPU and memory) of individual pods to match their actual usage

### 3. **Cluster Autoscaler**: Scales the number of nodes in a cluster up or down based on pending pods and resource requirements

* By utilizing autoscaling, Kubernetes ensures that applications remain highly available, responsive, and cost-efficient, even in fluctuating workloads.

[Reference](https://www.youtube.com/watch?v=jyBDbm1FHiM)
