terraform {
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.15.3"
    }
  }
}

provider "argocd" {
  server_addr = var.argocd_server_address
  username    = var.argocd_admin_username
  password    = var.argocd_password
  insecure    = true
  # grpc_web    = true
}