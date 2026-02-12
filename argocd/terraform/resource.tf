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
  depends_on          = [argocd_project.experiments]
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
    source_namespaces = ["*"]
    source_repos      = ["*"]
    sync_window {
      kind            = "deny"
      applications    = ["*"]
      schedule        = "* 10 * * *"
      duration        = "10m"
      manual_sync     = false
    }
  }
}

resource "argocd_application_set" "git_directories" {
  metadata {
    name = "git-directories"
  }

  spec {
    generator {
      git {
        repo_url = "https://github.com/argoproj/argo-cd.git"
        revision = "HEAD"

        directory {
          path = "applicationset/examples/git-generator-directory/cluster-addons/*"
        }

        directory {
          path    = "applicationset/examples/git-generator-directory/excludes/cluster-addons/exclude-helm-guestbook"
          exclude = true
        }
      }
    }

    template {
      metadata {
        name = "{{path.basename}}-git-directories"
      }

      spec {
        source {
          repo_url        = "https://github.com/argoproj/argo-cd.git"
          target_revision = "HEAD"
          path            = "{{path}}"
        }

        destination {
          server    = "https://kubernetes.default.svc"
          namespace = "{{path.basename}}"
        }
      }
    }
  }
}