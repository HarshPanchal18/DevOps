# External Secret Operator (ESO)

[Documentation](https://external-secrets.io/latest/introduction/getting-started/)

`External Secrets Operator` is a Kubernetes operator that integrates external secret management systems like AWS Secrets Manager, HashiCorp Vault, Google Secrets Manager, Azure Key Vault, IBM Cloud Secrets Manager, CyberArk Secrets Manager, Pulumi ESC and many more.

The operator reads information from external APIs and automatically injects the values into a Kubernetes `Secret`.

## What is the goal of External Secrets Operator?

The goal of External Secrets Operator is to synchronize secrets from external APIs into Kubernetes. ESO is a collection of custom API resources - `ExternalSecret`, `SecretStore`, and `ClusterSecretStore` that provide a user-friendly abstraction for the external API that stores and manages the lifecycle of the secrets for you.

## Cluster Setup overview

```text
k8s -> vault operator -> ESO -> SecretStore -> External Secret -> k8s secret created
```

## Install and configure Hashicorp vault first

## Install ESO via Helm chart

```bash
helm repo add external-secrets https://charts.external-secrets.io

helm install external-secrets \
    external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
    --set installCRDs=true
```

Wait for pods to up and running.

```bash
kubectl get pods -n external-secrets
```

## SecretStore

The idea behind the `SecretStore` resource is to separate concerns of authentication/access and the actual Secret and configuration needed for workloads.

The `ExternalSecret` specifies what to fetch, the `SecretStore` specifies how to access. This resource is `namespaced`.

The `SecretStore` contains references to secrets which hold credentials to access the external API.

## ExternalSecret

An `ExternalSecret` declares what data to fetch. It has a reference to a `SecretStore` which knows how to access that data. The **controller** uses that `ExternalSecret` as a blueprint to create secrets.

## Pull secrets from cluster to the key manager

1. Create a secret having **Initial Token** given by `vault`.
2. Create a `SecretStore` to authenticate the kubernetes with above secret.
3. Create an `ExternalSecret` to fetch `remote-secret` values via `path` and `key`
4. Adjust values accrodingly and apply manifests.
5. Check if a new secret(i.e. `example-sync`) is created inside our cluster having values of provided property(s).

Now go to the vault secret and change the value of a key. The change will reflect in a secret `example-sync`.

## Push secrets from cluster to the key manager

1. Create a secret having **Initial Token** given by `vault`.
2. Create a `SecretStore` to authenticate the kubernetes with above secret.
3. Create a `PushSecret` containing payload of the secret.
4. Adjust values accrodingly and apply manifests.
5. Check if a new secret given under **`pushSecret.spec.data[*].match.remoteRef.remoteKey`** (i.e. `vault-demo/do-not-delete`) is created in a key management (i.e. vault).
