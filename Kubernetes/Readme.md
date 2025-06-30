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

![Daemonset](https://images.viblo.asia/f3e48546-9b72-41bf-aa74-79cc354f06e6.png)

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

![RBAC Authorization](https://www.dnsstuff.com/wp-content/uploads/2019/10/role-based-access-control-1024x536.jpg)

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

    * To switch the context:

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

![Autoscaling in kubernetes](https://www.nops.io/wp-content/uploads/2023/06/Different-Methods-for-Autoscaling-in-Kubernetes.png)

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

## StorageClass, Persistent Volume, and Persistent Volume Claim in Kubernetes

Kubernetes provides a robust storage abstraction layer to manage storage resources independently from compute resources. Three key concepts form the foundation of this system: **StorageClass**, **Persistent Volume (PV)**, and **Persistent Volume Claim (PVC)**.

![StorageClass in kubernetes](https://blog.mayadata.io/hubfs/Storageclass%20blog%20%281%29-1.png)

---

### **StorageClass**

A **StorageClass** defines a "class" of storage offered by a Kubernetes cluster. It allows administrators to describe different types of storage (such as SSDs, HDDs, or network storage) and their properties, such as performance, latency, or backup policies. Each StorageClass specifies a provisioner (the plugin or driver responsible for creating storage), parameters (like storage type or performance level), and a reclaim policy (what happens to the storage when released).

* **Purpose**: Enables dynamic provisioning of storage resources.
* **Usage**: Developers can request a specific StorageClass in their PVCs, or rely on the default if none is specified.
* **Example**: A cluster may have a "fast-ssd" StorageClass for high-performance needs and a "standard" class for general use.

---

### **Persistent Volume (PV)**

A **Persistent Volume** is a cluster-wide storage resource that has been provisioned by an administrator or dynamically provisioned using a StorageClass. PVs are independent of any particular Pod and exist beyond the lifecycle of individual Pods, making them suitable for stateful applications.

* **Purpose**: Provides durable storage that persists even if Pods are deleted or recreated.
* **Types**: Can be backed by various storage systems (NFS, iSCSI, cloud storage, etc.).
* **Lifecycle**: PVs have their own lifecycle, separate from Pods, and are managed as first-class Kubernetes objects.

---

### **Persistent Volume Claim (PVC)**

A **Persistent Volume Claim** is a request for storage by a user or application. PVCs specify the desired storage size, access modes, and optionally the StorageClass. When a PVC is created, Kubernetes matches it to a suitable PV (either pre-provisioned or dynamically created via a StorageClass).

* **Purpose**: Allows users to request and consume storage resources without knowing the underlying details.
* **Usage**: A Pod references a PVC to use the storage; the PVC is then bound to a matching PV.
* **Dynamic Provisioning**: If a suitable PV does not exist, and a StorageClass is specified, Kubernetes can dynamically provision a new PV to satisfy the claim.

---

### **How They Work Together**

* **Administrators** define StorageClasses to describe available storage types.
* **Developers** create PVCs, optionally specifying a StorageClass.
* **Kubernetes** matches PVCs to available PVs, or dynamically provisions new PVs using the requested StorageClass.
* **Pods** mount PVCs to use persistent storage, ensuring data survives Pod restarts and rescheduling.

---

#### **Summary Table**

| Concept             | Description                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| StorageClass        | Defines storage types and properties for dynamic provisioning                |
| Persistent Volume   | Actual storage resource in the cluster, provisioned statically or dynamically|
| Persistent Volume Claim | User/application request for storage, matched to a PV                      |

---

This abstraction enables Kubernetes to manage storage resources flexibly and efficiently, supporting a wide range of application requirements and storage backends.

* Citations:

* [1] <https://kubernetes.io/docs/concepts/storage/storage-classes/>
* [2] <https://www.kubecost.com/kubernetes-best-practices/kubernetes-storage-class/>
* [3] <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>
* [4] <https://bluexp.netapp.com/blog/cvo-blg-kubernetes-storageclass-concepts-and-common-operations>
* [5] <https://spacelift.io/blog/kubernetes-persistent-volumes>
* [6] <https://bluexp.netapp.com/blog/cvo-blg-kubernetes-persistent-volume-claims-explained>
* [7] <https://www.kubermatic.com/blog/keeping-the-state-of-apps-5-introduction-to-storage-classes/>
* [8] <https://bluexp.netapp.com/blog/kubernetes-persistent-storage-why-where-and-how>
* [9] <https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/>
* [10] <https://thekubeguy.com/storage-classes-in-kubernetes-1bb62c6e937e>
* [11] <https://www.groundcover.com/blog/kubernetes-pvc>
* [12] <https://zesty.co/finops-glossary/kubernetes-persistent-volume-claim/>
* [13] <https://www.appvia.io/blog/demystifying-kubernetes-storage-classes>
* [14] <https://www.uffizzi.com/kubernetes-multi-tenancy/kubernetes-storage-class>
* [15] <https://aws.amazon.com/blogs/storage/persistent-storage-for-kubernetes/>
* [16] <https://kubernetes.io/docs/concepts/storage/volumes/>
* [17] <https://cloud.google.com/kubernetes-engine/docs/concepts/persistent-volumes>
* [18] <https://www.apptio.com/topics/kubernetes/best-practices/storage-class/>
* [19] <https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/>
* [20] <https://www.youtube.com/watch?v=BNKb-SOnoKk>
* [21] <https://www.purestorage.com/knowledge/what-is-kubernetes-persistent-volume.html>
* [22] <https://spot.io/resources/kubernetes-architecture/7-stages-in-the-life-of-a-kubernetes-persistent-volume-pv/>
* [23] <https://www.netapp.com/devops/what-is-kubernetes-persistent-volumes/>
* [24] <https://www.loft.sh/blog/kubernetes-persistent-volume>
* [25] <https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/manage-clusters/create-kubernetes-persistent-storage/manage-persistent-storage/about-persistent-storage>

---

Kubernetes does not define a fixed set of "types" of StorageClasses. Instead, a StorageClass is a customizable Kubernetes object that cluster administrators use to describe different storage offerings available in the cluster. The types and features of StorageClasses are determined by the underlying storage provisioners, their parameters, and policies set by the administrator[3].

### Common Types of StorageClasses

**StorageClasses are typically differentiated by:**

* The storage provisioner (e.g., AWS EBS, GCE PD, NFS, Ceph, CSI drivers, etc.)
* Performance characteristics (e.g., SSD vs. HDD, high IOPS, low latency)
* Data redundancy or backup policies
* Availability zones or regions
* Cost and reclaim policies

**Examples of StorageClass types:**

* Fast SSD storage
* Standard HDD storage
* Encrypted storage
* Replicated or multi-zone storage
* Low-latency storage
* Backup-enabled storage

**Each StorageClass includes fields such as:**

* `provisioner`: The driver or plugin that provisions the storage (e.g., `kubernetes.io/aws-ebs`, `kubernetes.io/gce-pd`, or a CSI driver).
* `parameters`: Key-value pairs for storage configuration (e.g., disk type, IOPS, encryption).
* `reclaimPolicy`: What happens to the storage after release (e.g., `Delete` or `Retain`).
* `allowVolumeExpansion`: Whether the volume can be resized.
* `volumeBindingMode`: When and how the volume is bound to a node[3].

**Sample StorageClass YAML:**

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  encrypted: "true"
reclaimPolicy: Delete
allowVolumeExpansion: true
```

#### Default StorageClass

You can mark one StorageClass as the default for the cluster. Any PersistentVolumeClaim (PVC) that does not specify a `storageClassName` will use the default StorageClass[3].

#### Summary Table

| StorageClass Example      | Provisioner                 | Purpose/Type             |
|--------------------------|-----------------------------|--------------------------|
| fast-ssd                 | AWS EBS, GCE PD, CSI driver | High-performance SSD     |
| standard-hdd             | AWS EBS, GCE PD, CSI driver | Cost-effective HDD       |
| encrypted-storage        | Any                         | Encrypted volumes        |
| replicated-multi-zone    | Cloud provider, CSI         | High-availability        |
| low-latency              | Custom CSI driver           | Low-latency workloads    |

**In summary:**
There is no fixed list of StorageClass "types" in Kubernetes; rather, StorageClasses are defined by the cluster administrator to represent the storage capabilities and policies available in the environment. The actual types depend on the storage systems and provisioners integrated with the Kubernetes cluster[3].

Citations:

* [1] <https://byjus.com/gate/storage-classes-in-c/>
* [2] <https://www.upgrad.com/blog/storage-classes-in-c/>
* [3] <https://kubernetes.io/docs/concepts/storage/storage-classes/>
* [4] <https://cloud.google.com/storage/docs/storage-classes>
* [5] <https://aws.amazon.com/s3/storage-classes/>
* [6] <https://www.shiksha.com/online-courses/articles/storage-classes-in-c/>
* [7] <https://www.nielit.gov.in/gorakhpur/sites/default/files/Gorakhpur/OLevel_2_B4_CLang_5May20_SS.pdf>
* [8] <https://www.codecademy.com/resources/docs/c/storage-classes>

---

### How do you set a default StorageClass in a Kubernetes cluster

To set a default StorageClass in a Kubernetes cluster, you need to annotate the desired StorageClass with `storageclass.kubernetes.io/is-default-class: "true"`. Here’s how you can do it:

1. **List existing StorageClasses** to see which one is currently set as default:

    ```bash
    kubectl get storageclass
    ```

    The default StorageClass will be marked with `(default)` in the output.

2. **Mark an existing StorageClass as non-default** (if needed) by removing or setting its annotation to `"false"`:

    ```bash
    kubectl patch storageclass  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
    ```

    Replace `` with the name of the current default StorageClass.

3. **Set your chosen StorageClass as the default** by adding or updating the annotation:

    ```bash
    kubectl patch storageclass  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    ```

    Replace `` with the name of the StorageClass you want as default.

4. **Verify the change**:

    ```bash
    kubectl get storageclass
    ```

    The new default will be marked with `(default)`.

#### Alternatively, when creating a new StorageClass, you can include this annotation directly in the manifest

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: my-storage-class
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner:
parameters:
  # ...
```

Then apply it with:

```bash
kubectl apply -f
```

**Note:**

* You can technically have more than one default StorageClass, but Kubernetes will use the most recently created one for PVCs without a specified `storageClassName`. It's best practice to have only one default[2].
* If you remove all default annotations, there will be no default StorageClass, and PVCs without a specified class will not be dynamically provisioned[2].

This process allows you to control which StorageClass is used by default for dynamic provisioning of storage in your cluster.

Citations:

* [1] <https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/>
* [2] <https://kubernetes.io/docs/concepts/storage/storage-classes/>
* [3] <https://cloud.google.com/kubernetes-engine/distributed-cloud/vmware/docs/how-to/default-storage-class>
* [4] <https://bluexp.netapp.com/blog/cvo-blg-kubernetes-storageclass-concepts-and-common-operations>
* [5] <https://www.edureka.co/community/52699/how-do-i-change-the-default-storageclass>
* [6] <https://cloud.google.com/kubernetes-engine/distributed-cloud/bare-metal/docs/installing/default-storage-class>
* [7] <https://docs.openshift.com/container-platform/4.13/storage/container_storage_interface/persistent-storage-csi-sc-manage.html>
* [8] <https://www.kubecost.com/kubernetes-best-practices/kubernetes-storage-class/>

---

### How does the reclaim policy affect PVs when a StorageClass is deleted

The reclaim policy of a Persistent Volume (PV) determines what happens to the underlying storage asset when its associated Persistent Volume Claim (PVC) is deleted-not when the StorageClass itself is deleted. Deleting a StorageClass has **no direct effect** on the reclaim policy or the lifecycle of existing PVs and PVCs.

Here’s how reclaim policy works in this context:

* **Retain:** If a PV's reclaim policy is set to `Retain`, deleting the PVC will release the PV, but the PV and its data will remain. The PV is not automatically deleted or made available for another claim until an administrator manually intervenes.
* **Delete:** If a PV's reclaim policy is `Delete`, deleting the PVC will also delete the PV and the underlying storage asset in the external infrastructure.

**When a StorageClass is deleted:**

* Existing PVs and PVCs that were provisioned using that StorageClass are unaffected and continue to follow their set reclaim policy.
* The reclaim policy of a PV does not change or trigger any action due to the deletion of the StorageClass.
* Only new dynamic provisioning using the deleted StorageClass is prevented.

**Summary:**
Deleting a StorageClass does not impact the reclaim policy or behavior of existing PVs. The reclaim policy continues to govern what happens when PVCs are deleted, regardless of the existence of the StorageClass.

Citations:

* [1] <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>
* [2] <https://kubernetes.io/docs/tasks/administer-cluster/change-pv-reclaim-policy/>
* [3] <https://docs.oracle.com/en-us/iaas/compute-cloud-at-customer/topics/oke/retaining-a-persistent-volume.htm>
* [4] <https://www.kubermatic.com/blog/keeping-the-state-of-apps-4-persistentvolumes-and-persistentvolum/>
* [5] <https://docs.redhat.com/en/documentation/red_hat_build_of_microshift/4.14/html/storage/understanding-persistent-storage-microshift>
* [6] <https://docs.openshift.com/container-platform/4.12/storage/understanding-persistent-storage.html>
* [7] <https://github.com/openebs/zfs-localpv/issues/507>
* [8] <https://github.com/jupyterhub/zero-to-jupyterhub-k8s/issues/901>

---

## What are StatefulSets in Kubernetes?

StatefulSets are designed to manage stateful applications that require persistent storage and ordering guarantees. They ensure that each Pod in the set has a unique identity and maintains its state across rescheduling.

![StatefulSet](https://www.vertica.com/wp-content/uploads/2021/05/Kubernetes-Statefulsets-Vertica.png)

Here's a sample YAML for a StatefulSet that demonstrates the basic components:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  replicas: 3
  serviceName: web
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:latest
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
```

This YAML defines a StatefulSet named `web` with 3 replicas, a service name `web`, and a container image `nginx:latest`. It also defines a volume claim template `www` that requests 1 GiB of storage. Each Pod in the set will have a unique identity and persistent storage.

### So if one of pod restarts, it will retain the previous states?

One of the key features of StatefulSets is that they maintain the state of each Pod across restarts. This is achieved through the use of Persistent Volumes (PVs) and Persistent Volume Claims (PVCs).

When a Pod restarts, the StatefulSet controller will:

1. Check if the Pod has a Persistent Volume Claim (PVC) associated with it.
2. If the PVC exists, the controller will attempt to mount the associated Persistent Volume (PV) to the new Pod.
3. The new Pod will retain the same identity and state as the previous Pod, including any data stored on the Persistent Volume.

This ensures that the Pod retains its state and any data it was processing before it restarted.

However, it's worth noting that the StatefulSet controller will only attempt to restore the state of a Pod if it has a matching Persistent Volume Claim (PVC) associated with it. If the PVC is deleted or not properly configured, the Pod will not retain its state across restarts.

## What are headless services in Kubernetes?

Headless services in Kubernetes are a special type of service that **do not have a cluster IP assigned**. This means that they do not load balance traffic to a set of Pods, but instead **allow direct access** to the individual Pods backing the service.

Instead of providing a single virtual IP and load balancing incoming requests across multiple pods, a headless service exposes the IP addresses of all the pods that match its selector directly through DNS.

Headless services are useful in scenarios where you need to:

1. **Directly reach individual Pods:** Clients can connect to specific Pods without going through a load balancer.
2. **Use StatefulSets:** Headless services are often used with StatefulSets to enable stable network identities for each Pod.
3. **Implement custom load balancing:** You can implement your own load balancing logic at the `application level`.

![Headless Service](https://www.middlewareinventory.com/wp-content/uploads/2023/04/Screenshot-2023-04-11-at-4.01.32-PM.png "Headless Service")

To create a headless service, you can set the `clusterIP` field to `None` in the service definition:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-headless-service
spec:
  clusterIP: None
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 8080
```

In this example, the service `my-headless-service` is headless, and clients can connect directly to the Pods selected by the label `app: my-app`.

### How Headless Services Work

* **DNS Resolution:** When a client queries the DNS for a headless service, it receives a list of the IPs of all pods backing the service, rather than a single service IP. This enables direct communication with any pod in the set.
* **No Load Balancing:** Kubernetes does not perform load balancing or proxying for headless services. Clients are responsible for choosing which pod to connect to, enabling custom load balancing or affinity strategies.
* **No ClusterIP:** There is **no virtual IP address**; the service is "headless" because it `lacks the usual single entry point`.

### Use Cases for Headless Services

Headless services are especially useful in scenarios where:

* **Stateful Applications:** Applications like databases (e.g., Cassandra, MongoDB) require clients to connect to specific pods to maintain data consistency and affinity.
* **Custom Service Discovery:** Applications need to discover and communicate with specific pods directly, often for advanced routing or peer-to-peer networking.
* **Microservices with Direct Pod Access:** Some microservices architectures benefit from bypassing a central load balancer to reduce latency or implement custom logic.

### Advantages

* **Direct Pod Communication:** Enables clients to connect to specific pods, which is crucial for stateful workloads and advanced networking patterns.
* **Custom Load Balancing:** Clients can implement their own load balancing strategies using the list of pod IPs returned by DNS.
* **Flexible Topologies:** Supports complex deployment patterns like distributed databases or peer-to-peer systems.

### Drawbacks

* **Increased DNS Dependency:** Relies heavily on the cluster's DNS service for service discovery, making DNS stability critical.
* **No Built-in Load Balancing:** Clients must handle load balancing and failover logic themselves, increasing application complexity.

### Summary Table: Headless vs Standard Kubernetes Service

| Feature                 | Standard Service (ClusterIP) | Headless Service              |
|-------------------------|------------------------------|-------------------------------|
| Cluster IP              | Yes                          | No (`clusterIP: None`)        |
| Load Balancing          | Yes (Kubernetes proxy)       | No (client-side only)         |
| DNS Resolution          | Single IP                    | List of pod IPs               |
| Use Cases               | Stateless apps, general LB   | Stateful apps, direct access  |
| Example Configuration   | `clusterIP:`                 | `clusterIP: None`             |

Headless services are a powerful tool in Kubernetes for applications that require direct, granular access to pods, especially in stateful or custom networking scenarios.

* [1] <https://stackoverflow.com/questions/52707840/what-is-a-headless-service-what-does-it-do-accomplish-and-what-are-some-legiti>
* [2] <https://kodekloud.com/blog/kubernetes-headless-service/>
* [3] <https://www.plural.sh/blog/kubernetes-headless-service-guide/>
* [4] <https://www.linkedin.com/pulse/exploring-kubernetes-headless-services-aditya-joshi>
* [5] <https://cloud.google.com/kubernetes-engine/docs/concepts/service>
* [6] <https://www.baeldung.com/ops/kubernetes-headless-service>
* [7] <https://kubernetes.io/docs/concepts/services-networking/service/>
* [8] <https://www.youtube.com/watch?v=TyhXO-Z-Z9A>
* [9] <https://www.middlewareinventory.com/blog/kubernetes-headless-service/>

### Why Headless Services Are Essential for Stateful Applications and Databases

**Headless services are critical for stateful applications and databases in Kubernetes because they enable direct, stable, and granular communication with individual pods—capabilities that are fundamental for maintaining data consistency, high availability, and correct application behavior.**

#### Direct Pod Access and Unique Identities

* **Direct Communication:** Stateful applications, such as distributed databases (e.g., Cassandra, MongoDB), often require that clients or other pods connect to specific instances (pods) rather than being load balanced across a pool. This is because each pod may hold unique data or play a specific role [such as primary/replica or leader/follower].
* **Stable Network Identity:** Headless services, when paired with StatefulSets, provide each pod with a stable DNS name and network identity. This ensures that even as pods are rescheduled or restarted, their identity remains consistent, which is crucial for stateful workloads.

#### Service Discovery and Data Consistency

* **DNS-Based Discovery:** Headless services expose each pod’s IP address through DNS, allowing clients and other services to discover and connect to individual pods directly. This DNS resolution is essential for applications that need to maintain persistent connections or must route requests to a particular instance for data consistency [e.g., always writing to the primary node in a database cluster].
* **Avoiding Load Balancer Interference:** Standard Kubernetes services load balance requests across all pods, which is not suitable for stateful applications where requests must be routed to a specific pod. Headless services bypass this load balancing, giving the application or client full control over which pod to communicate with.

#### Use Cases in Databases and StatefulSets

* **StatefulSets Integration:** StatefulSets use headless services to assign stable, unique DNS names to each pod (e.g., `pod-0.service.namespace.svc.cluster.local`). This is vital for distributed databases and stateful systems where each node has a distinct role or stores unique data.
* **High Availability and Persistence:** By ensuring each pod can be addressed individually and maintains a persistent identity, headless services help databases and stateful applications achieve high availability and prevent data corruption or loss during pod restarts or scaling events.

#### Summary Table: Headless Services vs Standard Services for Stateful Workloads

| Feature                    | Standard Service        | Headless Service            |
|----------------------------|-------------------------|-----------------------------|
| Load Balancing             | Yes (Kubernetes proxy)  | No (client/app controlled)  |
| Pod Discovery              | Single ClusterIP        | Individual pod DNS records  |
| Use Case                   | Stateless apps          | Stateful apps, databases    |
| Stable Pod Identity        | No                      | Yes                         |
| Direct Pod Communication   | No                      | Yes                         |

---

**In summary:** Headless services are essential for stateful applications and databases because they provide direct, stable, and granular access to individual pods. This enables proper service discovery, ensures data consistency, supports high availability, and aligns with the operational needs of distributed stateful systems in Kubernetes environments.

* [1] <https://portworx.com/knowledge-hub/understanding-statefulsets-in-kubernetes/>
* [2] <https://www.reddit.com/r/kubernetes/comments/12yrzme/why_do_we_need_headless_services/>
* [3] <https://stackoverflow.com/questions/50891104/how-does-statefulset-and-headless-service-works-k8s>
* [4] <https://www.plural.sh/blog/kubernetes-headless-service-guide/>
* [5] <https://devopsvoyager.hashnode.dev/headless-services-in-kubernetes>
* [6] <https://www.linkedin.com/pulse/exploring-kubernetes-headless-services-aditya-joshi>
* [7] <https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/>
* [8] <https://techdocs.broadcom.com/us/en/vmware-tanzu/standalone-components/tanzu-service-mesh/latest/tsm/using-tsm-GUID-38865240-F238-4699-AE75-171EC494F192.html>
* [9] <https://stackoverflow.com/questions/52707840/what-is-a-headless-service-what-does-it-do-accomplish-and-what-are-some-legiti>
* [10] <https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/>

### Challenges of Relying on DNS with Headless Services

Headless services in Kubernetes depend heavily on DNS for service discovery and direct pod communication. While this enables powerful patterns for stateful applications, it introduces several operational challenges:

1. **DNS Reliability and Stability**

    * Headless services require the Kubernetes DNS service to function reliably. If the DNS service is slow, misconfigured, or experiences outages, applications may fail to resolve pod addresses, resulting in communication errors or downtime.

2. **Pod IP Changes and DNS Propagation**

    * When pods are rescheduled, scaled, or restarted, their IP addresses can change. DNS records must be updated promptly to reflect these changes. Delays in DNS propagation can cause clients to receive outdated IPs, leading to failed connections or routing to the wrong pod.

3. **DNS Caching and Stale Records**

    * DNS components like CoreDNS may cache negative or outdated results (misses) for a set period (e.g., 30 seconds by default). This can delay the discovery of newly available pods or removal of terminated ones, causing startup failures or communication issues, especially in stateful workloads that require timely peer discovery.

4. **DNS Record Limits and Large Endpoints**

    * DNS protocol limitations restrict the number of records that can be returned in a single response. In services with a large number of endpoints (pods), not all IPs may be returned, potentially causing incomplete service discovery and uneven load distribution.

5. **Unstable DNS Query Results**

    * The order of IPs returned in DNS responses for headless services is not guaranteed to be stable. Clients that always connect to the first IP may unintentionally create uneven traffic distribution or affinity, which can be problematic for certain applications.

6. **Increased Complexity and Overhead**

    * Applications must implement their own logic for retrying failed DNS queries, handling DNS propagation delays, and managing direct connections to multiple pods. This adds complexity compared to using standard services with built-in load balancing.

---

**Summary:**
Relying on DNS with headless services introduces risks related to DNS stability, propagation delays, caching, record limits, and the need for custom client-side logic. These challenges must be carefully managed to ensure reliable operation of stateful applications and microservices architectures that depend on direct pod communication.

* [1] <https://www.plural.sh/blog/kubernetes-headless-service-guide/>
* [2] <https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/>
* [3] <https://www.linkedin.com/pulse/headless-services-direct-pod-access-kubernetes-christopher-adamson-3lsic>
* [4] <https://gist.github.com/aojea/32aeaa86aacebcdd93596ecb70fcba4f>
* [5] <https://stackoverflow.com/questions/71533293/my-understanding-of-headless-service-in-k8s-and-two-questions-to-verify>
* [6] <https://github.com/kubernetes/kubernetes/issues/92559>
* [7] <https://edgedelta.com/company/blog/kubernetes-services-types>
* [8] <https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/dns/troubleshoot-dns-failures-across-an-aks-cluster-in-real-time>
* [9] programming.microservices

### How Direct Pod Communication Improves Database Performance

Direct pod communication, enabled by Kubernetes headless services, offers several performance advantages for databases and stateful applications:

1. **Reduced Latency**

    * Direct communication bypasses the Kubernetes service proxy and built-in load balancer, allowing clients to connect straight to the intended database pod. This minimizes the number of network hops and reduces latency, which is especially important for high-throughput and low-latency database workloads.

2. **Efficient Resource Utilization**

    * By connecting directly to specific pods, clients avoid unnecessary proxying and load balancing, which can introduce overhead. This leads to more efficient use of network and compute resources, as requests are routed exactly where needed.

3. **Improved Throughput**

    * With direct access, clients can distribute queries or transactions across database pods according to application logic or partitioning schemes. This can increase overall throughput, as each pod can be utilized to its full capacity without bottlenecks introduced by a centralized load balancer.

4. **Custom Load Balancing and Affinity**

    * Direct pod communication enables applications to implement custom load balancing strategies, such as routing requests to the pod holding the relevant data partition or maintaining session affinity. This is critical for distributed databases, where certain queries must be handled by specific nodes for data consistency and optimal performance.

5. **Enhanced High Availability**

    * In distributed databases, clients often need to detect and connect to healthy pods directly, rerouting around failed nodes. Headless services make this possible by exposing up-to-date DNS records for each pod, allowing for rapid failover and improved availability.

6. **Supports Stateful and Partitioned Workloads**

    * Many databases require that clients connect to specific nodes that store particular data shards or act as leaders/primaries. Direct communication ensures that requests reach the correct pod, supporting stateful and partitioned workload requirements.

> "Direct pod access is the defining feature: Headless Services provide unique DNS records for each pod, enabling direct communication and bypassing Kubernetes' built-in load balancing. This is essential for applications requiring granular control over pod interactions, such as stateful sets and distributed databases."

---

**In summary:**
Direct pod communication improves database performance by reducing latency, increasing throughput, enabling custom routing and affinity, and supporting high availability and stateful workloads. Headless services make these benefits possible by allowing clients to discover and connect to individual pods directly, rather than routing all traffic through a centralized load balancer.

* [1] <https://stackoverflow.blog/2020/10/14/improve-database-performance-with-connection-pooling/>
* [2] <https://overcast.blog/11-ways-to-optimize-network-performance-in-kubernetes-9531a69c10c0>
* [3] <https://www.plural.sh/blog/kubernetes-headless-service-guide/>
* [4] <https://www.percona.com/blog/how-container-networking-affects-database-performance/>
* [5] <https://kubeops.net/blog/navigating-the-network-a-comprehensive-guide-to-kubernetes-networking-models>
* [6] <https://www.redhat.com/en/blog/kubernetes-pods-communicate-nodes>
* [7] <https://www.tigera.io/blog/deep-dive/optimizing-for-high-availability-and-minimal-latency-in-distributed-databases-with-kubernetes-and-calico-cluster-mesh/>
* [8] <https://kubernetes.io/docs/concepts/services-networking/>
