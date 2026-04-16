variable "name_prefix" {
  type        = string
  default     = "grocery-mern-app-dev"
  description = "Prefix for naming secrets and tags, e.g. 'grocery-mern-app-dev/app-secrets'"
}
variable "create_secret_shells" {
  type    = bool
  default = true
}
