resource "kubernetes_pod_v1" "nginx" {
    metadata {
        name    = var.pod_name
        labels  = {
            app = "nginx"
        }
    }
    spec {
        container {
            image = var.container_image
            name  = "nginx"
        }
    }
}