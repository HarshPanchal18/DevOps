# Istio

## Installations

- Download latest istio.

```bash
curl -L https://istio.io/downloadIstio | sh -
```

- Add istio/bin to `PATH`.

```bash
export PATH=$PWD/bin:$PATH
```

- Install Istio.

```bash
istioctl install
```

- Install with default profile.

- Remove taint on node if you're perfroming on a single node cluster.

```bash
kubectl taint node master node-role.kubernetes.io/control-plane:NoSchedule-
```

- Verify installation via checking pods.

```bash
kubectl get pods -n istio-system
```

- By default the pod won't have `envoy` proxies attached to it. So we have to inject proxies inside pod.
- Label the namespace of this pod.

```bash
kubectl label ns default istio-injection=enabled
```

- Deploy a demo of microservice application from the /sample directory inside the downloaded `.tar` of Istio.
- Follow the READMEs of samples accordingly.
- You may need to remove resource request in case pod went in pending...
