# Ingress

In Kubernetes, an Ingress is _an object that allows access to Kubernetes services from outside the Kubernetes cluster._

You can configure access by creating a collection of rules that define which inbound connections reach which services.

An Ingress can be configured to give Services externally-reachable URLs, load balance traffic, terminate SSL/TLS, and offer name-based virtual hosting. Ingress lets you configure an HTTP load balancer for applications running on Kubernetes, represented by one or more Kubernetes internal Services.

An Ingress controller is responsible for fulfilling the Ingress, usually with a load balancer, though it may also configure your edge router or additional frontends to help handle the traffic.

The Ingress spec has all the information needed to configure a load balancer or proxy server. It contains a list of rules matched against all incoming requests. Ingress provides routing rules to manage external users’ access to the services in a Kubernetes cluster, typically via HTTPS/HTTP.

With Ingress, you can easily set up rules for routing traffic without creating a bunch of Load Balancers or exposing each service on the node. This makes it the best option to use in production environments.

An Ingress does not expose arbitrary ports or protocols. Exposing services other than HTTP and HTTPS to the internet typically uses a service of type NodePort or LoadBalancer.

> Ingress is not a Service type, but it acts as the entry point for the cluster.

Ingress also enables configuration of resilience (time-outs, rate limiting), content-based routing, authentication and much more.

## Use cases

* Externally reachable URLs for applications deployed in Kubernetes clusters.

* Load balancing rules and traffic, as well as TLS/SSL termination for each hostname, such as `foo.example.com`.

* Content-based routing:

    1. `Host-based routing`: For example, routing requests with the host header `foo.example.com` to one group of services and the host header `bar.example.com` to another group.

    2. `Path-based routing`: For example, routing requests with the URI that starts with `/serviceA` to service A and requests with the URI that starts with `/serviceB` to service B.

## Example

```yaml
apiVersion: v1
kind: Ingress
metadata:
    name: my-ingress

spec:
    rules:
    - host: example.com
        http:
            paths:
            - path: /foo
                pathType: Prefix
                backend:
                    service:
                        name: foo-service
                        port:
                            number: 3000

            - path: /bar
                pathType: Prefix
                backend:
                    service:
                        name: bar-service
                        port:
                            number: 6000

    - host: "*.example.com*"
        http:
            paths:
            - path: /foo
                backend:
                    service:
                        name: all-service
                        port:
                            number: 7000
```

* A Kubernetes Ingress is a robust way to expose Kubernetes services outside the cluster.

* It lets you consolidate your routing rules to a single resource, and gives a powerful options for configuring these rules, by allowing an API Gateway style of traffic routing.
