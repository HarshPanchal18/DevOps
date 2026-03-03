resource "kubernetes_pod" "nginx" {
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