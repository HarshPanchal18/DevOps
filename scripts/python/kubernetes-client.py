from kubernetes import config, client

config.load_kube_config()

v1 = client.CoreV1Api()

print("Listing pods with theis IPs and Image(s)")

resource = v1.list_namespaced_pod("kube-system")

for pod in resource.items:
        print("%s\t%s\t%s\t" % (pod.status.pod_ip, pod.metadata.namespace, pod.metadata.name), end=" ")
        for container in pod.spec.containers:
                print(container.image)