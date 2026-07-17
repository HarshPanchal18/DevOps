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
