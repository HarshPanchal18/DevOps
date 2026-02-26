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
