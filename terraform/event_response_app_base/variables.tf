# -----------------------------------------------------------------------------
# Input variables
# -----------------------------------------------------------------------------
variable "ecs_cluster_arn" {
  description = "ARN of the existing ECS cluster (EC2 launch type)."
  type        = string
}

variable "vpc_id" {
  description = "ID of the existing VPC."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks and EFS mount targets."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB (optional; required if enable_alb is true)."
  type        = list(string)
  default     = []
}

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
