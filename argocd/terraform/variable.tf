variable "username" {
  type = string
  description = "Username value"
}

variable "password" {
  type = string
  sensitive = true
  description = "Password"
}

variable "server_address" {
  type = string
  sensitive = true
  description = "ArgoCD Server address"
}