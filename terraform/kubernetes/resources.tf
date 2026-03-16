resource "kubernetes_pod_v1" "nginx" {
  metadata {
    name = "nginx-example"
    labels = {
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

resource "kubernetes_deployment_v1" "nginx-deploy" {
  metadata {
    name = var.nginx-deploy-name
    labels = {
      app = "nginx-deploy"
    }
  }
  spec {
    replicas = var.nginx-replicas
    selector {
      match_labels = {
        app = "nginx-deploy"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx-deploy"
        }
      }
      spec {
        container {
          image = var.nginx-image
          name  = "nginx"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "nginx" {
  metadata {
    name = "svc-nginx"
  }
  spec {
    selector = {
      app = "nginx-deploy"
    }
    type = "NodePort"
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_config_map_v1" "example_cm" {
  metadata {
    name = "example-cm"
  }
  data = {
    "foo" = "bar"
  }
}

resource "kubernetes_secret_v1" "example_secret" {
  metadata {
    name = "example-secret"
  }
  type = "Opaque"
  data = {
    "password" = base64encode("verysecret")
  }
  # string_data = {
  #     password = data.external.db_credentials.result
  # }
}

module "pod" {
  source = "./pod-module"

  container_image = "nginx:1.25.4"
  pod_name        = "nginx-1-25"
}