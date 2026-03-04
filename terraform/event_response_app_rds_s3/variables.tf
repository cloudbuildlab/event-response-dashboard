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

# Managed RDS (PostgreSQL)
variable "rds_instance_class" {
  description = "RDS instance class (e.g. db.t3.micro)."
  type        = string
  default     = "db.t3.micro"
}
variable "rds_allocated_storage" {
  description = "Allocated storage in GB."
  type        = number
  default     = 20
}
variable "rds_engine_version" {
  description = "PostgreSQL engine version (e.g. 15 or 16)."
  type        = string
  default     = "16"
}
variable "rds_database_name" {
  description = "Name of the default database to create."
  type        = string
  default     = "appdb"
}
variable "rds_master_username" {
  description = "Master username for the RDS instance."
  type        = string
  default     = "appuser"
}
variable "rds_multi_az" {
  description = "Deploy RDS in Multi-AZ."
  type        = bool
  default     = false
}

# Managed S3
variable "s3_bucket_prefix" {
  description = "Prefix for the managed S3 bucket name (bucket = prefix-environment-app_name-account_id)."
  type        = string
  default     = "event-response"
}
variable "s3_force_destroy" {
  description = "Allow destroying the bucket even if it has objects (use with care)."
  type        = bool
  default     = false
}
