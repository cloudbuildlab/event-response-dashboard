# -----------------------------------------------------------------------------
# Input variables
# -----------------------------------------------------------------------------
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

variable "fastschema_event_schema_b64" {
  description = "Optional: base64-encoded event schema JSON. When set, written to FastSchema data/schemas so the web app can create events without using the dashboard. Leave empty to create the schema manually in the FastSchema dashboard."
  type        = string
  default     = "eyJuYW1lIjoiZXZlbnQiLCJuYW1lc3BhY2UiOiJldmVudHMiLCJsYWJlbF9maWVsZCI6InRpdGxlIiwiZmllbGRzIjpbeyJ0eXBlIjoic3RyaW5nIiwibmFtZSI6InRpdGxlIiwibGFiZWwiOiJUaXRsZSJ9LHsidHlwZSI6InN0cmluZyIsIm5hbWUiOiJkZXNjcmlwdGlvbiIsImxhYmVsIjoiRGVzY3JpcHRpb24iLCJvcHRpb25hbCI6dHJ1ZX1dfQ=="
  sensitive   = true
}

variable "web_image" {
  description = "Container image for the Go web app (e.g. ghcr.io/platformfuzz/event-response-image:latest)."
  type        = string
  default     = "ghcr.io/platformfuzz/event-response-image:latest"
}
variable "web_port" {
  description = "Port the web container listens on (e.g. 8080)."
  type        = number
  default     = 8080
}

# External RDS (PostgreSQL)
variable "rds_endpoint" {
  description = "RDS instance endpoint (hostname). Leave empty to omit RDS env vars."
  type        = string
  default     = ""
}
variable "rds_port" {
  type    = number
  default = 5432
}
variable "rds_database" {
  type    = string
  default = ""
}
variable "rds_username" {
  type    = string
  default = ""
}
variable "rds_password" {
  type      = string
  default   = ""
  sensitive = true
}

# External S3
variable "s3_bucket_name" {
  description = "S3 bucket name for app storage. Leave empty to omit S3 env and IAM."
  type        = string
  default     = ""
}
