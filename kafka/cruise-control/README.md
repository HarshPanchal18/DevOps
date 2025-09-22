# Kafka Rebalance using Cruise Control

A solution for the failure management problem.

## Key features

- Multi-goal rebalance proposal generation
- Rack-awareness (no more than one replica of each partition resides in the same rack.)
- Resource capacity violation checks (CPU, DISK, Network I/O) for each broker
- Per-broker replica count violation check
- Resource utilization balance (CPU, DISK, Network I/O) average
- Leader traffic distribution (similar no. of Leader replica for all brokers)
- Rebalance the current partition topology (optimize current partitions)
- Rebalance on newly added brokers
- Rebalance before removing brokers

## Architecture

![Cruise Control Architecture](https://github.com/linkedin/cruise-control/raw/migrate_to_kafka_2_4/docs/images/architecture.png)

### Components

#### Metrics Reporter

- Fetches and stores Kafka metrics.

#### Load Monitor

- collects Kafka metrics from the cluster and derives per partition resource metrics that are not directly available. (special partition level CPU utilization which isn’t available in Kafka)
- then generates a workload model(internal picture of the cluster) that accurately captures cluster resource utilization (incl. CPU, Disk IO, etc.)
- organizes metrics into time based windows.
- feed metrics into the anomaly detector and the analyzer.

#### Analyzer

- brain of Cruise Control.
- creates an optimization proposals based on the workload model from the load monitor and configured goals.

#### Goals

- define how an optimal cluster utilization would look.
- E.x. a goal can say that the CPU utilization of brokers must not exceed 85%
  2 types of Goals
    1) Hard goal - hard goals are satisfied first and they must be satisfied to get a valid optimization proposal.
    2) Soft goal - if soft goals aren’t satisfied then a proposal can still be valid.

  Cruise Control allows users to write their own goals to optimize a Kafka cluster in whichever way they want.
  Rebalance occurs when the current cluster state violates one or more of the specified goals, according to the thresholds set in Cruise Control’s configuration.

  The thresholds for each goal are defined in the Cruise Control server configuration, not in the KafkaRebalance resource.

  ```properties
  cpu.balance.threshold=1.10
  cpu.capacity.threshold=0.80
  ```

  These mean: rebalance if a broker’s CPU utilization is more than 10% above the average, or if a broker’s CPU utilization exceeds 80% of its capacity.

#### Anomaly Detector

Interval can be configured with `proposal.expiration.ms` (default: 15min)

- Continuously monitors the health and performance of the Kafka cluster, checking for things like broker failures or disk capacity issues, that could impact cluster stability.
- Identify differnet types of anomaly.
  1. Broker failure - when a non-empty broker leaves the cluster unexpectedly and doesn’t come back within a defined grace period of time.
  2. Disk failure - when Cruise Control is used with JBOD then a non-empty disk might die which causes partitions to go offline.
  3. Goal Violation - when an optimization goal is violated.
  4. Metric Anomaly - out of order value in a collected metric

#### Anomaly Notifier

- users can enable actions to be taken in response to an anomaly by turning self-healing on for the relevant anomaly detectors

  - `fix` - fix the problem right away (e.g. start a rebalance, fix offline replicas). Runs when self healing is enabled.
  - `check` - check the situation again after a configurable delay (e.g. adopt a grace period before fixing broker failures)
  - `ignore` - ignore the anomaly (e.g. self-healing is disabled)

#### Executor

- responsible for carrying out the optimization proposals from the analyzer and execute it to rebalance the cluster.
- it only executes the proposal if it is approved via annotation strimzi.io/rebalance:approve

#### REST API

- to allow strimzi operator to interact with Cruise Control
- supports querying the load and optimization proposals of the Kafka cluster, as well as triggering admin operations
- You can view supported [API endpoints](https://github.com/linkedin/cruise-control/wiki/REST-APIs)

##### Role of the REST API in Cruise Control

Cruise Control exposes a **REST API** (usually on port `9090`) which is the **only way to interact with it**.
Through this API, you can:

- Request optimization proposals (rebalance plans).
- Execute proposals (apply rebalance).
- Query cluster load, broker stats, partition distribution.
- Perform cluster maintenance actions (add/remove brokers, fix anomalies).

Essentially, the REST API is the control surface for Cruise Control.

---

##### Who interacts with the REST API?

In **Strimzi**, you as a user don’t normally call the REST API directly. Instead:

1. **Strimzi Kafka Operator**

   - The operator talks to Cruise Control REST API on your behalf.
   - When you create a `KafkaRebalance` CR, the operator translates that into REST API calls to Cruise Control.
   - The operator also polls the REST API to check proposal status, execution progress, and anomalies.

2. **End Users (Optional)**

   - In a raw Kafka + Cruise Control setup (without Strimzi), admins would directly send `curl` requests to the Cruise Control REST API.
   - In Strimzi-managed clusters, this is abstracted away, but you *can* expose the REST API externally (not recommended unless you want manual control).

---

##### How does interaction happen in Strimzi?

Example flow:

1. You create a `KafkaRebalance` CR.
2. Strimzi operator calls Cruise Control REST API `GET /proposals` → gets an optimization proposal.
3. Operator updates the CR status to `ProposalReady`.
4. You `approve` rebalance via annotation.
5. Operator calls Cruise Control REST API `POST /proposals?json=true&dryrun=false` → executes the rebalance.
6. Operator polls REST API endpoints to update CR status (`Rebalancing → Ready`).

---

##### Why REST API is kept?

Even though Strimzi shields you from it:

- It’s still useful for debugging or advanced ops (e.g., running ad-hoc queries about broker load).
- Strimzi’s implementation is modular — if tomorrow they support more Cruise Control features, it’s just a matter of mapping more CR fields to REST API calls.
- If you bypass Strimzi, you could directly use `curl` to hit Cruise Control REST endpoints.

##### How can I manually hit the GET url to view proposals, for example `/proposals`?

## Activate Cruise Control in Kafka cluster

```yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka

metadata:
    name: my-cluster

spec:
    kafka: {}
    cruiseControl: {}
```

## Rebalance Workflow states

| Phase           | Meaning                                   |
| --------------- | ----------------------------------------- |
| `New`           | Created — operator is evaluating it       |
| `ProposalReady` | Cruise Control prepared optimization plan |
| `Ready`         | Ready to execute rebalance                |
| `Rebalancing`   | Rebalance in progress                     |
| `Stopped`       | Completed or stopped                      |
| `NotReady`      | There is an error detected while evaluating. Describe KafkaRebalance to know more|

## Rebalancing happens when

- a consumer is down and doesn’t send heartbeats to the coordinator
- a consumer is idle, so it’s considered as “failed” by the coordinator
- a new consumer joins the group
- a failed consumer rejoins the group
- number of partitions in the topic is changed

## Rebalance procedures

### 1. Create/Apply a rebalance plan

```yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaRebalance
metadata:
  name: my-rebalance
  namespace: kafka-namespace # replace with your namespace
spec:
  goals:
    - RackAwareGoal
    - DiskCapacityGoal
    - NetworkInboundCapacityGoal
    - NetworkOutboundCapacityGoal
    - CpuCapacityGoal
    - ReplicaCapacityGoal
    - PotentialNwOutGoal
  skipHardGoalCheck: true
```

### 2. Apply the rebalance once the `my-rebalance` is in `ProposalReady` state

```bash
kubectl annotate kafkarebalance my-rebalance strimzi.io/rebalance=approve -n myproject
```

This will cause the operator to move the Kafka Rebalance into `Rebalancing` state.

### 3. Monitoring progress

```bash
kubectl get kafkarebalance my-rebalance -n myproject -o yaml
```

Look under:

```yaml
status:
  conditions:
    - type: Ready
      status: "True"
```

Once `Ready` is true — rebalance is complete.

## Limitations of using Cruise Control

In the context of Apache Kafka, there are a few potential limitations to the Cruise Control feature:

1. **Complexity**: Cruise Control is a relatively complex feature in Kafka, with many configuration options and parameters to manage. This complexity can make it challenging for some users to set up and optimize Cruise Control for their specific use case.

2. **Resource Utilization**: Cruise Control requires additional computational resources to continuously monitor the Kafka cluster and make optimization decisions. This can add overhead to the overall Kafka deployment, especially in clusters with limited resources.

3. **Responsiveness**: Cruise Control operates on a periodic schedule, which means that it may not be able to respond to immediate changes or issues in the Kafka cluster. This can be a limitation in scenarios where rapid adjustments are required.

4. **Compatibility**: Cruise Control is tightly integrated with the Kafka ecosystem, and its functionality may be limited when used in conjunction with other third-party tools or custom Kafka configurations.

5. **Automation Limitations**: While Cruise Control aims to automate many cluster management tasks, it may not be able to handle all possible scenarios or edge cases. Operators may still need to intervene manually in some situations.

6. **Monitoring and Alerting**: Cruise Control provides some monitoring and alerting capabilities, but these may not be as comprehensive or customizable as those provided by dedicated monitoring solutions. This can make it more challenging to integrate Cruise Control with existing monitoring and alerting infrastructure.

7. **Learning Curve**: Effectively using Cruise Control requires a certain level of understanding of Kafka internals and optimization strategies. This learning curve can be a barrier for some users, especially those new to Kafka.

## Metrics before-after Rebalancing

When a Kafka rebalance proposal reaches the ProposalReady state (on prepared optimization plan), Strimzi creates a ConfigMap (named after the KafkaRebalance custom resource) containing a JSON string of broker metrics generated from Cruise Control.

Each broker has a set of key metrics represented by three values:

- The current metric value before the optimization proposal is applied
- The expected metric value after applying the proposal
- The difference between the two values (after minus before)

This ConfigMap remains accessible even after the rebalance completes.

```bash
kubectl get configmap -n myproject kafka-data-rebalance -oyaml
```

### Properties captured in the configmap

- **leaders** - The number of replicas on this broker that are partition leaders.
- **replicas** - The number of replicas on this broker.
- **cpuPercentage** - The CPU utilization as a percentage of the defined capacity.
- **diskUsedPercentage** - The disk utilization as a percentage of the defined capacity.
- **diskUsedMB** - The absolute disk usage in MB.
- **networkOutRate** - The total network output rate for the broker.
- **leaderNetworkInRate** - The network input rate for all partition leader replicas on this broker.
- **followerNetworkInRate** - The network input rate for all follower replicas on this broker.
- **potentialMaxNetworkOutRate** - The hypothetical maximum network output rate that would be realized if this broker became the leader of all the replicas it currently hosts."

## Useful Goals in High to Low priority

- **RackAwareGoal** - No more than one replica of each partition resides in the same rack.
- **MinTopicLeadersPerBrokerGoal** - Ensure that each alive broker has at least a certain number of leader replica of each topic
- **ReplicaCapacityGoal** - Ensure that the max number of replicas per broker is under the specified maximum limit.
- **DiskCapacityGoal** - Ensure Disk space usage of each broker is below a given threshold.
- **NetworkInboundCapacityGoal** - Ensure Inbound network utilization of each broker is below a given threshold.
- **NetworkOutboundCapacityGoal** - Ensure Outbound network utilization of each broker is below a given threshold.
- **CpuCapacityGoal** - Ensure CPU utilization of each broker is below a given threshold.
- **ReplicaDistributionGoal** - Make all the brokers in a cluster have a similar number of replicas.
- **DiskUsageDistributionGoal** - Keep the Disk space usage variance among brokers within a certain range relative to the average Disk utilization.
- **CpuUsageDistributionGoal** - Keep the CPU usage variance among brokers within a certain range relative to the average CPU utilization.
- **LeaderReplicaDistributionGoal** - Make all the brokers in a cluster have a similar number of leader replicas.
- **TopicReplicaDistributionGoal** - Maintain an even distribution of any topic's partitions across the entire cluster.

## Some of the Configuration

### Goals in config

- goals: (Define scope of Goals) The master goals list.
To limit the optimization goals that cluster's Cruise Control server can use.

- hard.goals: (Goals required to validate) List of goals will define which goals in the master goals list are considered hard and cannot be violated in any of the optimization functions of Cruise Control.
Try to make it as short as possible.

- deafult.goals: (For proposal generation) By default, every 15 mins, Cruise Control will use the current state of your Kafka cluster to generate a cached optimization proposal using the configured default.goals list.

```yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
    name: my-cluster
spec:
    kafka: {}
    cruiseControl:
        config:
            # Note that `goals` must be a superset of `default.goals` and `hard.goals`
            goals: >
                com.linkedin.kafka.cruisecontrol.analyzer.goals.RackAwareGoal,
                com.linkedin.kafka.cruisecontrol.analyzer.goals.MinTopicLeadersPerBrokerGoal,
                com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal,
                com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskCapacityGoal,
                com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundCapacityGoal,
                com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundCapacityGoal,
                com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuCapacityGoal,
            default.goals: >
                com.linkedin.kafka.cruisecontrol.analyzer.goals.RackAwareGoal,
                com.linkedin.kafka.cruisecontrol.analyzer.goals.MinTopicLeadersPerBrokerGoal,
            hard.goals: >
                com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal,
                com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskCapacityGoal,
                com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundCapacityGoal,
                com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundCapacityGoal,
                com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuCapacityGoal
            cpu.balance.threshold: 1.1
            metadata.max.age.ms: 300000
            send.buffer.bytes: 131072
            self.healing.enabled: true
            anomaly.notifier.class: com.linkedin.kafka.cruisecontrol.detector.notifier.SelfHealingNotifier
            webserver.http.cors.enabled: true
            webserver.http.cors.origin: "*"
            webserver.http.cors.exposeheaders: "User-Task-ID,Content-Type"
        # ...
```

### `skipHardGoalCheck: true`

Whether to allow the hard goals specified in the Kafka CR to be skipped in optimization proposal generation.

Useful when some of those hard goals are preventing a balance solution being found. Default is false.

While describing KafkaRebalance:

```yaml
Status:
Conditions:
Last Transition Time:  2025-09-04T06:21:21.058931949Z
"Message:               Server returned: Error processing POST request '/rebalance' due to: 'com.linkedin.kafka.cruisecontrol.exception.KafkaCruiseControlException: java.lang.IllegalArgumentException: Missing hard goals [NetworkInboundCapacityGoal, DiskCapacityGoal, RackAwareGoal, NetworkOutboundCapacityGoal, CpuCapacityGoal, ReplicaCapacityGoal] in the provided goals: [CpuCapacityGoal, DiskCapacityGoal, RackAwareGoal, MinTopicLeadersPerBrokerGoal, ReplicaCapacityGoal]. Add `skip_hard_goal_check=true` parameter to ignore this sanity check.'."
Reason:                CruiseControlRestException
Status:                True
Type:                  NotReady
```

- [Reference](https://strimzi.io/blog/2020/06/15/cruise-control/)
- [Reference](https://github.com/strimzi/strimzi-kafka-operator/blob/0.45.0/documentation/modules/cruise-control/con-cruise-control-overview.adoc#skipping-hard-goal-checks)

## Troubleshootings

>2025-09-11 05:38:18 WARN  KafkaClusterCreator:201 - Reconciliation #53(timer) Kafka(myproject/kafka-data): Cannot scale down brokers [2] because [2] have assigned partition-replicas
>2025-09-11 05:38:18 WARN  KafkaClusterCreator:238 - Reconciliation #53(timer) Kafka(myproject/kafka-data): Reverting scale-down of Kafka kafka-data by changing number of replicas to 3

```bash
kubectl annotate Kafka -n myproject kafka-data strimzi.io/skip-broker-scaledown-check="true"
```

- [Reference](https://strimzi.io/blog/2024/01/03/prevent-broker-scale-down-if-containing-paritition-replicas/)
