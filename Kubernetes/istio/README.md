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

## Traffic Management in Istio

Istio's traffic routing:

- Let you easily control the flow of traffic and API calls between services.
- Simplifies configuration of timeouts, retries, A/B testing, canary rollouts, staged rollouts with traffic splits based on percentage.

### Envoy

- The high-performance proxy that Istio uses to mediate inbound and outbound traffic for all services in the service mesh.
- All traffic that mesh services send-receive is proxied through Envoy to easily direct and control traffic around your mesh without making changes to application services.

### Virtual Services

- Lets you configure **how requests are routed to a service** within an Istio service mesh.
- Consists of a set of routing rules evaluated in order, letting Istio match each request to the virtual service to a specific real destination in a service mesh.
- Routing rules in the virtual service that tell Envoy how to send the virtual service’s traffic to appropriate destinations. Route destinations can be different versions of the same service or entirely different services.

Usecase: send traffic to different versions of a service, specified as service subsets

- Clients send request to the VS host as if it is a single entity, and Envoy then routes the traffic to the different versions defined in VS rules. e.x. _20% of calls go to the new version_

The traffic routing is completely separate from the instance deployment, meaning that the number of instances implementing the new service version can scale up and down based on traffic load without referring to traffic routing at all.

Following example to route requests to different versions of a service depending on whether the request comes from a particular user

```yaml
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v3
```

`hosts` - the address(es) the client uses when sending requests to the service. Can be an IP, a DNS, or Kubernetes service FQDN.

- Use wildcard (*) prefixes to create a single set of routing rules for all matching services.

`http` - contains the VS's routing, describe match conditions and actions for routing HTTP(s) and gRPC traffic sent to one or more `hosts`

`match` - let you flow the traffic based on condition and matchings.

- You can ser `match` conditions on traffic ports, header fields, URIs, etc.

- Below example lets user send traffic to two separate services (ratings and reviews)

    ```yaml
    spec:
        hosts:
            - bookinfo.com
        http:
        - match:
            - uri:
                prefix: /reviews
          route:
            - destination:
                host: reviews
        - match:
            - uri:
                prefix: /ratings
          route:
            - destination:
                host: ratings
    ```

- You can add multiple conditions inside `match` for ANDed conditions, or add multiple `match` to the same rule to OR conditions.

In addition, you can destribute traffic by `weight`.

```yaml
spec:
  hosts:
    - reviews
  http:
    - route:
        - destination:
            host: reviews
            subset: v1
          weight: 75
        - destination:
            host: reviews
            subset: v2
          weight: 25
```

`destination` - specifies the actual destination for traffic that matches this condition.

- It must be a real destination that exists in Istio service registry (`reviews.namespace.svc`)

## Example [Bookinfo](https://istio.io/latest/docs/examples/bookinfo/) sample (samples/bookinfo)

![BookInfo Architecture](/Kubernetes/istio/Bookinfo-architecture.svg)

1. Change directory to the root of the Istio installation.

2. The default Istio installation uses `automatic sidecar injection`. Label the namespace that will host the application with `istio-injection=enabled`:

    ```bash
    kubectl label namespace default istio-injection=enabled
    ```

3. Deploy your application using the `kubectl` command:

    ```bash
    kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
    ```

    - The command launches all four services shown in the bookinfo application architecture diagram. All 3 versions of the reviews service, v1, v2, and v3, are started.

4. Confirm all services and pods are correctly defined and running:

    ```bash
    $ kubectl get services
    NAME          TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
    details       ClusterIP   10.0.0.31    <none>        9080/TCP   6m
    kubernetes    ClusterIP   10.0.0.1     <none>        443/TCP    7d
    productpage   ClusterIP   10.0.0.120   <none>        9080/TCP   6m
    ratings       ClusterIP   10.0.0.15    <none>        9080/TCP   6m
    reviews       ClusterIP   10.0.0.170   <none>        9080/TCP   6m
    ```

    ```bash
    $ kubectl get pods
    NAME                             READY     STATUS    RESTARTS   AGE
    details-v1-1520924117-48z17      2/2       Running   0          6m
    productpage-v1-560495357-jk1lz   2/2       Running   0          6m
    ratings-v1-734492171-rnr5l       2/2       Running   0          6m
    reviews-v1-874083890-f0qf0       2/2       Running   0          6m
    reviews-v2-1343845940-b34q5      2/2       Running   0          6m
    reviews-v3-1813607990-8ch52      2/2       Running   0          6m
    ```

5. To confirm that the Bookinfo application is running, send a request to it by a curl command from some pod, for example from ratings:

    ```bash
    $ kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"
    <title>Simple Bookstore App</title>
    ```

6. Create a Gateway for bookinfo.

    - Make the application accessible from outside of your Kubernetes cluster, e.g., from a browser.
    - A gateway is used for this purpose.

    ```bash
    kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
    ```

    - Confirm the gateway has been created.

    ```bash
    kubectl get gateway
    ```

7. Access product page at

    ```bash
    curl http://HOST:GATEWAY-HTTP-PORT/productpage
    ```

## [Kiali](https://istio.io/latest/docs/ops/integrations/kiali/) Dashboard

1. Install Kiali through YAML.

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.26/samples/addons/kiali.yaml
    ```

2. Change `kiali` service type from `ClusterIP` to `NodePort` for accessing dashboard on browser.
