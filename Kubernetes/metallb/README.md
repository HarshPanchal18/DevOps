# MetalLB

1. Install MetalLB

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
    ```

2. Apply below manifest to assign an `External-IP` from IP pool.

    ```yaml
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    metadata:
        name: default-address-pool
        namespace: metallb-system
    spec:
        addresses:
            - 192.168.54.240-192.168.54.250
    ---
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    metadata:
        name: l2
        namespace: metallb-system
    ```
