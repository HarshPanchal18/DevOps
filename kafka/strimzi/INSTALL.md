# Installation [Reference](https://github.com/strimzi/strimzi-kafka-operator)

## Zookeeper (<=0.45.0)

1. Create namespace `myproject`.

    ```bash
    kubectl create namespace myproject
    ```

2. Apply all the YAMLs from install/cluster-operator directorty of version `0.45.0`.

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

3. Check logs of strimzi operator.

    ```bash
    kubectl logs -n myproject afka strimzi-cluster-operator
    ```

    - If operator is unable to get kubernetes version, set kubernets version manually inside **`deployment`**.

        `2025-06-06 10:53:19 ERROR PlatformFeaturesAvailability:138 - Detection of Kubernetes version failed.`

        OR

        `Caused by: com.fasterxml.jackson.databind.exc.UnrecognizedPropertyException: Unrecognized field "emulationMajor" (class io.fabric8.kubernetes.client.VersionInfo), not marked as ignorable (9 known properties: "goVersion", "gitTreeState", "platform", "minor", "gitVersion", "gitCommit", "buildDate", "compiler", "major"])`

    - Set the kubernetes version manually by running the following command:
    [Reference](https://github.com/strimzi/strimzi-kafka-operator/issues/11386)

    ```bash
    kubectl set env deployment/strimzi-cluster-operator STRIMZI_KUBERNETES_VERSION="major=1,minor=33"
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

## Teardown

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
