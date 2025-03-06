# Short Definitions

## NodePort

A NodePort service in Kubernetes is a _type of service_ that **exposes an application running on a set of Pods to external traffic.** It allocates a static port on each Node's IP address, allowing external clients to access the service using `<NodeIP>:<NodePort>.`

This type of service is _useful for exposing services to the outside world without needing an external load balancer._
