# OPA - Open Policy Agent

## Installations

### Install gatekeeper

```bash
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm repo update
helm install gatekeeper gatekeeper/gatekeeper \
  --namespace gatekeeper-system --create-namespace \
  --version 3.19.2
```

### Install OPA

```bash
helm install opa opa/opa \
  --namespace opa --create-namespace \
  --set kubeMgmt.enabled=true \
  --set kubeMgmt.replica=true \
  --set opa.tlsCertFile=/certs/tls.crt \
  --set opa.tlsPrivateKeyFile=/certs/tls.key

helm repo add opa https://open-policy-agent.github.io/kube-mgmt/charts
helm repo update
helm upgrade -i -n opa --create-namespace opa opa/opa
```

### Teardown

```bash
helm repo remove gatekeeper
helm uninstall gatekeeper -n gatekeeper-system
kubectl delete ns gatekeeper-system
```

## [Mutation](https://open-policy-agent.github.io/gatekeeper/website/docs/mutation/) in Gate-keeper

Gatekeeper's mutation feature allows for **modifying Kubernetes resources at request time** through customizable mutation policies. These policies are defined using specific Custom Resource Definitions (CRDs) called **mutators**.

There are four types of mutators:

- **AssignMetadata**: Used for changes to the metadata section of a resource, specifically limited to adding labels and annotations. Pre-existing labels and annotations cannot be modified.
- **Assign**: For any changes outside the metadata section of a resource.
- **ModifySet**: Adds or removes entries from a list as if it were a set, appending new values to the end of a list. The operation can be `merge` to insert values or `prune` to remove them.
- **AssignImage**: Specifically designed for changing components of an image string, such as the domain, path, or tag.

Each mutation CRD is divided into three sections:

1. **Extent(Area) of changes**: Describes **which resources will be mutated**, using match criteria similar to constraints. This includes fields like `scope`, `kinds`, `labelSelect`, `namespaces`, `namespaceSelector`, `excludedNamespaces`, and `name`. The `applyTo` field is required for all mutators except `AssignMetadata`.

2. **Intent**: Specifies **what should be changed** in the resource. This involves a `location` element for the path to be modified and `parameters.assign.value` for the new value, which can be a simple string or a composite value. Wildcards can be used for list element values in `location`. Values can also be assigned from metadata using the `fromMetadata` field (e.g., `namespace` or `name`).

3. **Conditional**: Defines **conditions under which the mutation will be applied**, using `pathTests` to check if a specified path exists or does not exist.

### Examples

Here are some examples of YAML configurations for different mutation scenarios:

**Adding an annotation using `AssignMetadata`**:

```yaml
apiVersion: mutations.gatekeeper.sh/v1
kind: AssignMetadata
metadata:
  name: demo-annotation-owner
spec:
  match:
    scope: Namespaced # Scope of the mutated resource.
  location: "metadata.annotations.owner" # Location to modify.
  parameters:
    assign:
      value: "admin" # Default value to assign on location.
```

**Setting security context of a specific container to non-privileged using `Assign`**:

```yaml
apiVersion: mutations.gatekeeper.sh/v1
kind: Assign
metadata:
  name: demo-privileged
spec:
  applyTo:
    - groups:["]
      kinds: ["Pod"]
      versions: ["v1"]
  match:
    scope: Namespaced # Scope of the mutated resource.
    kinds:
      - apiGroups: ["*"]
        kinds: ["Pod"]
    namespaces: ["bar"] # Match only Pods in the "bar" namespace
  location: "spec.containers[name:foo].securityContext.privileged" # Path to modify.
  parameters:
    assign:
      value: false # New value to assign.
    pathTests: # Conditions for applying the mutation.
      - subPath: "spec.containers[name:foo]" # Path to check.
        condition: MustExist # Condition that must be true for the mutation to apply.
```

**Setting `imagePullPolicy` to `Always` for all containers except in the `system` namespace using `Assign`**:

```yaml
apiVersion: mutations.gatekeeper.sh/v1
kind: Assign
metadata:
  name: demo-image-pull-policy
spec:
  applyTo:
    - groups: [""]
      kinds: ["Pod"]
      versions: ["v1"]
  match:
    scope: Namespaced
    kinds:
      - apiGroups: ["*"]
        kinds: ["Pod"]
    excludedNamespaces: ["system"]
  location: "spec.containers[name:*].imagePullPolicy"
  parameters:
    assign:
      value: Always
```

**Adding a `network` sidecar to a Pod using `Assign`**:

```yaml
apiVersion: mutations.gatekeeper.sh/v1
kind: Assign
metadata:
  name: demo-sidecar
spec:
  applyTo:
    - groups: [""]
      kinds: ["Pod"]
      versions: ["v1"]
  match:
    scope: Namespaced
    kinds:
      - apiGroups: ["*"]
        kinds: ["Pod"]
  location: "spec.containers[name:networking]"
  parameters:
    assign:
      value:
        name: "networking"
        imagePullPolicy: Always
        image: quay.io/foo/bar:latest
        command: ["/bin/bash", "-c", "sleep INF"]
```

**Adding `dnsPolicy` and `dnsConfig` to a Pod using `Assign`**:

```yaml
apiVersion: mutations.gatekeeper.sh/v1
kind: Assign
metadata:
  name: demo-dns-policy
spec:
  applyTo:
    - groups: [""]
      kinds: ["Pod"]
      versions: ["v1"]
  match:
    scope: Namespaced
    kinds:
      - apiGroups: ["*"]
        kinds: ["Pod"]
  location: "spec.dnsPolicy"
  parameters:
    assign:
      value: None
---
apiVersion: mutations.gatekeeper.sh/v1
kind: Assign
metadata:
  name: demo-dns-config
spec:
  applyTo:
    - groups: [""]
      kinds: ["Pod"]
      versions: ["v1"]
  match:
    scope: Namespaced
    kinds:
      - apiGroups: ["*"]
        kinds: ["Pod"]
  location: "spec.dnsConfig"
  parameters:
    assign:
      value:
        nameservers:
        - 1.2.3.4
```

**Setting a Pod's container image to use a specific digest using `AssignImage`**:

```yaml
apiVersion: mutations.gatekeeper.sh/v1alpha1
kind: AssignImage
metadata:
  name: add-nginx-digest
spec:
  applyTo:
    - groups: [ "" ]
      kinds: [ "Pod" ]
      versions: [ "v1" ]
  location: "spec.containers[name:nginx].image"
  parameters:
    assignTag: "@sha256:abcde67890123456789abc345678901a"
  match:
    source: "All"
    scope: Namespaced
    kinds:
      - apiGroups: [ "*" ]
        kinds: [ "Pod" ]
```

**Remove argmuent `--alsologtostderr` from all containers using `ModifySet`**:

```yaml
apiVersion: mutations.gatekeeper.sh/v1
kind: ModifySet
metadata:
  name: remove-err-logging
spec:
  applyTo:
  - groups: [""]
    kinds: ["Pod"]
    versions: ["v1"]
  location: "spec.containers[name: *].args"
  parameters:
    operation: prune
    values:
      fromList:
        - --alsologtostderr
```
