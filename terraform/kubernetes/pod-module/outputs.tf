output "pod_name" {
    value = kubernetes_pod.nginx.metadata
}