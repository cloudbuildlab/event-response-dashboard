variable "ecs_cluster_arn" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids" { type = list(string) }

variable "environment" {
  type    = string
  default = "dev"
}
variable "desired_count" {
  type    = number
  default = 1
}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "fastschema_image" {
  type    = string
  default = "ghcr.io/fastschema/fastschema:latest"
}
variable "app_port" {
  type    = number
  default = 8000
}
variable "fastschema_app_key" {
  type      = string
  default   = ""
  sensitive = true
}
variable "fastschema_admin_username" {
  type    = string
  default = ""
}
variable "fastschema_admin_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "web_image" {
  description = "Container image for the Go web app (built from app/)."
  type        = string
}
variable "web_port" {
  description = "Port the web container listens on (e.g. 8080)."
  type        = number
  default     = 8080
}
