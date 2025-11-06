resource "kubernetes_pod" "nginx" {
    metadata {
        name    = "nginx-example"
        labels  = {
            app = "nginx"
        }
    }
    spec {
        container {
            image = "nginx:1.19"
            name  = "nginx"
        }
    }
}

resource "kubernetes_deployment" "nginx-deploy" {
    metadata {
        name    = "nginx-deployment"
        labels  = {
            app = "nginx-deploy"
        }
    }
    spec {
        replicas = 3
        selector {
            match_labels = {
                app      = "nginx-deploy"
            }
        }
        template {
            metadata {
                labels  = {
                    app = "nginx-deploy"
                }
            }
            spec {
                container {
                    image = "nginx:1.19"
                    name  = "nginx"
                }
            }
        }
    }
}

resource "kubernetes_service" "nginx" {
    metadata {
        name = "svc-nginx"
    }
    spec {
        selector = {
            app = "nginx-deploy"
        }
        type = "NodePort"
        port {
            port       = 80
            target_port = 80
        }
    }
}