resource "kubernetes_pod" "nginx" {
    metadata {
        name = "nginx-example"
        labels = {
            app = "nginx"
        }
    }

    spec {
        container {
            iamge = "nginx:1.19"
            name  = "nginx"
        }
    }
}