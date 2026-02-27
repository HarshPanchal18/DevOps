# Sealed Secrets

## Installation

Install sealed-secret contoller:

```bash
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.35.0/controller.yaml
```

Verify controller installation:

```bash
kubectl get pods -n kube-system -l name=sealed-secrets-controller
```

Install sealed secret via Helm:

```bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm search repo sealed-secrets --versions
helm install sealed-secrets -n sealed-secrets sealed-secrets/sealed-secrets --create-namespace
```

You should now be able to create sealed secrets.

Check logs of `sealed-secrets` pod of namespace `sealed-secrets`

```bash
kubectl logs -n sealed-secrets -l app.kubernetes.io/instance=sealed-secrets
```

The new key is created inside a kubernetes secret (i.e. `sealed-secrets-keyc9pzr`) to seal secrets:

```bash
kubectl get secrets -n sealed-secrets sealed-secrets-keyc9pzr -oyaml
```

This key is renewed every 30 day (by default) so that the latest key remains active.

You can configure renewal period inside `deployment/sealed-secrets`'s `.spec.template.spec.containers[].args` under **--key-renew-period** as `720h` or set `keyrenewperiod` in helm `values.yaml`. Set **"0"** to disable the rotation.

Old ones are kept there in just case an old sealed secret needs to be decrypted. If you lose these encryption keys, you may not be able to retireve the secrets from the sealed secrets

### Install the client-side tool kubeseal

```bash
curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.35.0/kubeseal-0.35.0-linux-amd64.tar.gz"
tar -xvzf kubeseal-0.35.0-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```

## Create a Sealed Secret

Run below command to create a sealed secret through **TTY**

```bash
kubeseal
```

Paste secret content in terminal. For example:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
stringData:
  secret.json: |-
    {
      "apikey": "secret-api-key"
    }
```

New sealed secret will be created based on above provided secret.

```json
{
  "kind": "SealedSecret",
  "apiVersion": "bitnami.com/v1alpha1",
  "metadata": {
    "name": "mysecret",
    "namespace": "default"
  },
  "spec": {
    "template": {
      "metadata": {
        "name": "mysecret",
        "namespace": "default"
      },
      "type": "Opaque"
    },
    "encryptedData": {
      "secret.json": "AgAlP2o2/zXhPRR0a9rjsLyCfA5rPHlOgNZBxaGsxp05t1PI0eg+P8/8rOrkf3POVe2+/lYRzyhZxQquPWddgGIU0a2PSDU7/aKYk/T4BEjg0qXQNOvywfGe7gpKjggVqGtkEKrlbmneNx/JQ/Vfy1AZuR9nT6MBXlMaJqmFl2q3Em6glvpWiNB1bH6LvcfssjZh2F7GFnrE9Y39T0IEaxBJo8VrsegVaJNi6h/sr234PF1A0j0NZxmnc9BCGUtfAGcy16PYRJHmhcKBmCAXCAJonNNGAx8yqVGfjrKXWZO5Fn6eV9RFLbso3735XXrgdM+/TYfgxkCQ04Ab2nMm0dhfGjHcq8k6tKltR+QI2yBUwes2lzKIz+3sa0i3Ii/lf62/6MKeQ8v4tZ51XI+45U6SCe5j6dAI8v5GzeO5XAmNUAAr2p3TNtSksFJsAaTkOepTjsEcE2chCWlLgYXbcsV+053U1rJqjXoOgoHz33ly+0oy2YXe6c/1ROsbsDTYduELpwjJRJ8Yq+OXirAt1j6yQ+UcswhzooEedK+MVhPb7YRr4R36fII3/uXCVQZziXjL/ta6e5x0JiRbTwz0HuRpJEX5bcfcByaWvng=="
    }
  }
}
```

To automate this way,

```bash
cat secret.yaml | kubeseal -oyaml > sealed-secret.yaml
```

Or

```bash
kubeseal -oyaml secret.yaml > sealed-secret.yaml
```

Apply this sealed secret

```bash
kubectl apply -f Sealed-secret.yaml
```

1. Create a sealed secret file of secret having literal `foo: bar` running the command below:

    ```bash
    kubectl create secret generic secret-name --dry-run=client --from-literal=foo=bar -o yaml | \
    kubeseal --controller-name=sealed-secrets --controller-namespace=sealed-secrets --format yaml > mysealedsecret.yaml
    ```

    The file `mysealedsecret.yaml` is a commitable file.

    If you would rather not need access to the cluster to generate the sealed secret you can run:

    ```bash
    kubeseal --controller-name=sealed-secrets --controller-namespace=sealed-secrets --fetch-cert > mycert.pem
    ```

    to retrieve the public cert used for encryption and store it locally. You can then run `kubeseal --cert mycert.pem` instead to use the local cert e.g.

    ```bash
    kubectl create secret generic secret-name --dry-run=client --from-literal=foo=bar -o yaml | \
    kubeseal --controller-name=sealed-secrets --controller-namespace=sealed-secrets --format yaml --cert mycert.pem > mysealedsecret.yaml
    ```

2. Apply the sealed secret

    ```bash
    kubectl create -f mysealedsecret.yaml
    ```

Running `kubectl get secret secret-name -o yaml` will show the decrypted secret that was generated from the sealed secret.

Both the SealedSecret and generated Secret **must have the same name and namespace.**

## Backup encryption keys

```bash
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -oyaml > sealed-secrets-keys.key
```
