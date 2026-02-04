variable "argocd_admin_username" {
  default = "admin"
  type        = string
  description = "ArgoCD Username"
}

variable "argocd_username" {
  default = "local-user"
  type        = string
  description = "ArgoCD Username"
}

variable "argocd_password" {
  type        = string
  sensitive   = true
  description = "ArgoCD Password"
}

variable "argocd_server_address" {
  default = "172.20.0.3:30080"
  type        = string
  sensitive   = true
  description = "ArgoCD Server address"
}

variable "argocd_namespace" {
  default     = "argocd"
  type        = string
  description = "Kubernetes namespace where ArgoCD Application is created"
}

variable "destination_k8s_server" {
  default     = "https://kubernetes.default.svc"
  type        = string
  sensitive   = true
  description = "Kubernetes Cluster URL where ArgoCD Applications are going to create"
}