resource "argocd_application" "app-helm-redis" {
  metadata {
    name              = "app-helm-redis"
    namespace         = var.argocd_namespace
  }
  spec {
    project           = "default"
    destination {
      namespace       = "default"
      server          = var.destination_k8s_server
    }
    source {
      repo_url        = "https://charts.bitnami.com/bitnami"
      chart           = "redis"
      target_revision = "24.1.2"
      helm {
        release_name  = "redis"
      }
    }
    sync_policy {
      automated {
        self_heal     = true
      }
      sync_options    = ["CreateNamespace=true", "ApplyOutOfSyncOnly=false"]
    }
  }
}

resource "argocd_application" "app-kustomize-dev" {
  depends_on          = [ argocd_project.experiments ]
  metadata {
    name              = "app-kustomize-dev"
    namespace         = var.argocd_namespace
  }
	spec {
    project           = argocd_project.experiments.metadata[0].name
    destination {
      namespace       = "default"
      server          = var.destination_k8s_server
    }
    source {
      repo_url        = "https://github.com/HarshPanchal18/argocd-application"
      target_revision = "main"
      path            = "kustomize/overlays/dev"
    }
  }
}

resource "argocd_project" "experiments" {
  metadata {
    name              = "experiments"
  }
  spec {
    description       = "Experiment space for applications"
    destination {
      namespace       = "*"
      server          = var.destination_k8s_server
    }
    source_namespaces = [ "*" ]
    source_repos      = [ "*" ]
    sync_window {
      kind            = "deny"
      applications    = [ "*" ]
      schedule        = "* 10 * * *"
      duration        = "10m"
      manual_sync     = false
    }
  }
}