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
