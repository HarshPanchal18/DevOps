terraform {
  required_providers {
    argocd = {
      source  = "oboukili/argocd"
      version = "6.0.2"
    }
  }
}

provider "argocd" {
  server_addr = var.server_address
  username = var.username
  password = var.password
}