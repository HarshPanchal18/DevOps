# Installation [Reference](https://github.com/strimzi/strimzi-kafka-operator)

## Kafka & Zookeeper (<=0.45.0)

1. Create namespace `myproject`.

    ```bash
    kubectl create namespace myproject
    ```

2. Apply all the YAMLs from install/cluster-operator directorty of version `0.45.0` to deploy `Strimzi Operator`.

    ```bash
    kubectl apply -n myproject \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/010-ServiceAccount-strimzi-cluster-operator.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/020-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/020-RoleBinding-strimzi-cluster-operator.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/021-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/021-ClusterRoleBinding-strimzi-cluster-operator.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/022-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/022-RoleBinding-strimzi-cluster-operator.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/023-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/023-RoleBinding-strimzi-cluster-operator.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/030-ClusterRole-strimzi-kafka-broker.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/030-ClusterRoleBinding-strimzi-cluster-operator-kafka-broker-delegation.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/031-ClusterRole-strimzi-entity-operator.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/033-ClusterRole-strimzi-kafka-client.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/033-ClusterRoleBinding-strimzi-cluster-operator-kafka-client-delegation.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/040-Crd-kafka.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/041-Crd-kafkaconnect.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/042-Crd-strimzipodset.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/043-Crd-kafkatopic.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/044-Crd-kafkauser.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/045-Crd-kafkamirrormaker.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/046-Crd-kafkabridge.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/047-Crd-kafkaconnector.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/048-Crd-kafkamirrormaker2.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/049-Crd-kafkarebalance.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/04A-Crd-kafkanodepool.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/050-ConfigMap-strimzi-cluster-operator.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/060-Deployment-strimzi-cluster-operator.yaml
    ```

3. **[DEBUG]:** Check logs of strimzi operator.

    ```bash
    kubectl logs -n myproject kafka strimzi-cluster-operator
    ```

    - If operator is unable to get kubernetes version, set kubernets version manually inside **`deployment`**.

        `2025-06-06 10:53:19 ERROR PlatformFeaturesAvailability:138 - Detection of Kubernetes version failed.`

        OR

        `Caused by: com.fasterxml.jackson.databind.exc.UnrecognizedPropertyException: Unrecognized field "emulationMajor" (class io.fabric8.kubernetes.client.VersionInfo), not marked as ignorable (9 known properties: "goVersion", "gitTreeState", "platform", "minor", "gitVersion", "gitCommit", "buildDate", "compiler", "major"])`

    - Set the kubernetes version manually by running the following command:
    [Reference](https://github.com/strimzi/strimzi-kafka-operator/issues/11386)

    ```bash
    kubectl set env deployment/strimzi-cluster-operator -n myproject STRIMZI_KUBERNETES_VERSION="major=1,minor=33"
    ```

    - If above command says that `deployment/strimzi-cluster-operator not found`, then you need to manually append the environment variable inside `strimzi-cluster-operator` YAML file.

    ```bash
    kubectl edit deployment strimzi-cluster-operator -n myproject
    ```

    - Add the following environment variable under `spec.template.spec.containers.env` section:

    ```yaml
    ...
    spec:
        template:
            spec:
                containers:
                    env:
                    ...
                    - name: STRIMZI_KUBERNETES_VERSION
                      value: "major=1,minor=33"
                    ...
    ```

    - Save and exit editor.
    - Verify that the operator is running properly.

    ```bash
    kubectl get pods -n myproject
    ```

4. Create PVs and StorageClass for Zookeeper and Kafka.

    - Create directories for PVs and then apply `pv.yml`.

    ```bash
    mkdir -p /home/$USER/volume/zookeeper-data # Verify with path inside pv.yml
    mkdir -p /home/$USER/volume/kafka-data # Verify with path inside pv.yml
    kubectl create -f pv.yml
    ```

5. Create a Kafka cluster.

    - Apply `kafka.yml`.

    ```bash
    kubectl create -f kafka.yml
    ```

    - Wait for pod start creating.
    - If zookeeper and kafka pods doesn't start creating,

    Describe Kafka CRD using

    ```bash
    kubectl describe kafka -n myproject kafka-data
    ```

    `Message: Exceeded timeout of 300000ms while waiting for Pods resource kafka-data-zookeeper-0 in namespace myproject to be ready`

    - If you see the above message, then you need to increase the timeout value in `deployment` .yaml file. Located at `spec.template.spec.containers.env` section.

    ```yaml
    STRIMZI_OPERATION_TIMEOUT_MS: "600000" # or more
    ```

## Send and Receive Messages

1. With the cluster running, run a simple producer to send messages to a Kafka topic (the topic is automatically created):

    ```bash
    kubectl -n myproject run kafka-producer -ti --image=quay.io/strimzi/kafka:0.46.0-kafka-4.0.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server kafka-data-kafka-bootstrap:9092 --topic mytopic
    ```

    In case the operation times out, you can increase the timeout value in the `deployment` YAML file under `spec.template.spec.containers.env` section:

    ```yaml
    STRIMZI_OPERATION_TIMEOUT_MS: "600000" # or more
    ```

    **OR**

    In case of getting warning messages such as `The metadata response from the cluster reported a recoverable issue with correlation id 6 : {my-topic=UNKNOWN_TOPIC_OR_PARTITION} (org.apache.kafka.clients.NetworkClient)`, it means that `mytopic` does not exist yet, and you can create a topic manually before running the producer:

    ```bash
    kubectl -n myproject run kafka-topic-create -ti --image=quay.io/strimzi/kafka:0.46.0-kafka-4.0.0 --rm=true --restart=Never -- bin/kafka-topics.sh --bootstrap-server kafka-data-kafka-bootstrap:9092 --create --topic mytopic --partitions 1 --replication-factor 1
    ```

    This command will create a topic named `mytopic` with 1 partition and a replication factor of 1.

    - Check if the topic is created successfully:

    ```bash
    kubectl -n myproject run kafka-topic-list -ti --image=quay.io/strimzi/kafka:0.46.0-kafka-4.0.0 --rm=true --restart=Never -- \
    bin/kafka-topics.sh --bootstrap-server kafka-data-kafka-bootstrap:9092 --list
    ```

    - To make sure this doesn't happen again, you can enable the auto topic creation feature in Kafka by setting the `kafka.spec.config.auto.create.topics.enable` property to `true` in the Kafka configuration. This is usually enabled by default, but you can verify it in your Kafka configuration file or through the Strimzi Kafka custom resource.

    - Once everything is set up correctly, you’ll see a prompt where you can type in your messages:

    ```text
    If you don't see a command prompt, try pressing enter.
    >Hello Harsh!
    ```

2. And to receive them in a different terminal, run:

    ```bash
    kubectl -n myproject run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.46.0-kafka-4.0.0 --rm=true --restart=Never -- \
    bin/kafka-console-consumer.sh --bootstrap-server kafka-data-kafka-bootstrap:9092 --topic mytopic --from-beginning
    ```

    - You should see the messages you sent from the producer:

    ```text
    Hello Harsh!
    ```

## Teardown

- Deleting your Apache Kafka cluster

    ```bash
    kubectl -n myproject delete $(kubectl get strimzi -o name -n myproject)
    ```

- Deleting the PVC.

    ```bash
    kubectl delete pvc -n myproject --all
    ```

- Deleting the Strimzi cluster operator

    ```bash
    kubectl delete -n myproject \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/010-ServiceAccount-strimzi-cluster-operator.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/020-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/020-RoleBinding-strimzi-cluster-operator.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/021-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/021-ClusterRoleBinding-strimzi-cluster-operator.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/022-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/022-RoleBinding-strimzi-cluster-operator.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/023-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/023-RoleBinding-strimzi-cluster-operator.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/030-ClusterRole-strimzi-kafka-broker.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/030-ClusterRoleBinding-strimzi-cluster-operator-kafka-broker-delegation.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/031-ClusterRole-strimzi-entity-operator.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/033-ClusterRole-strimzi-kafka-client.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/033-ClusterRoleBinding-strimzi-cluster-operator-kafka-client-delegation.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/040-Crd-kafka.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/041-Crd-kafkaconnect.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/042-Crd-strimzipodset.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/043-Crd-kafkatopic.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/044-Crd-kafkauser.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/045-Crd-kafkamirrormaker.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/046-Crd-kafkabridge.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/047-Crd-kafkaconnector.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/048-Crd-kafkamirrormaker2.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/049-Crd-kafkarebalance.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/04A-Crd-kafkanodepool.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/050-ConfigMap-strimzi-cluster-operator.yaml \
        -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/060-Deployment-strimzi-cluster-operator.yaml
    ```

- Deleting `myproject` namespace.

    ```bash
    kubectl delete namespace myproject
    ```
