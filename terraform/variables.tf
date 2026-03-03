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
  description = "Environment name (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "app_key_secret_arn" {
  description = "Optional ARN of Secrets Manager secret containing APP_KEY (32-char value). If not set, FastSchema generates and persists it under /fastschema/data."
  type        = string
  default     = ""
}

variable "fastschema_image" {
  description = "FastSchema container image."
  type        = string
  default     = "ghcr.io/fastschema/fastschema:latest"
}
