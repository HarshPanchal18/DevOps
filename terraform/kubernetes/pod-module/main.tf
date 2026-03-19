resource "kubernetes_pod_v1" "nginx" {
    metadata {
        name    = var.pod_name
        labels  = {
            app = "nginx"
            env = format("%s", terraform.workspace)
        }
    }
    spec {
        container {
            image = var.container_image
            name  = "nginx"
        }
    }
}