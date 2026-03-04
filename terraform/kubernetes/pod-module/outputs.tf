output "pod_name" {
    value = kubernetes_pod_v1.nginx.metadata
}