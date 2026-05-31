variable "secrets" {
  type    = map(object({ value = string }))
  default = {}
}
