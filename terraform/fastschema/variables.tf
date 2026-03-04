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

variable "enable_alb" {
  description = "Create an Application Load Balancer for FastSchema."
  type        = bool
  default     = true
}

variable "desired_count" {
  description = "Number of FastSchema tasks to run."
  type        = number
  default     = 1
}

variable "environment" {
  description = "Environment name, used as prefix in resource names (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "fastschema_app_key" {
  description = "APP_KEY value (32-char) for FastSchema. If set, stored in SSM Parameter Store and injected into the task. If not set, FastSchema generates and persists it under /fastschema/data."
  type        = string
  default     = ""
  sensitive   = true
}

variable "fastschema_admin_username" {
  description = "Admin username; stored in SSM, injected as ADMIN_USER. When set with fastschema_admin_password, container runs 'fastschema setup' at start so you can log in with these credentials (see FastSchema cmd/main.go)."
  type        = string
  default     = ""
}

variable "fastschema_admin_password" {
  description = "Admin password; stored in SSM, injected as ADMIN_PASS. When set with fastschema_admin_username, container runs 'fastschema setup' at start so you can log in with these credentials."
  type        = string
  default     = ""
  sensitive   = true
}

variable "app_port" {
  description = "Port the FastSchema app listens on (default 8000)."
  type        = number
  default     = 8000
}

variable "fastschema_image" {
  description = "FastSchema container image."
  type        = string
  default     = "ghcr.io/fastschema/fastschema:latest"
}

variable "tags" {
  description = "Tags to apply to all taggable resources. Merged with resource-specific tags."
  type        = map(string)
  default     = {}
}
