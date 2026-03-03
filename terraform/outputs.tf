output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = var.ecs_cluster_arn
}

output "ecs_service_name" {
  description = "Name of the FastSchema ECS service."
  value       = aws_ecs_service.fastschema.name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer (if ALB is enabled)."
  value       = var.enable_alb ? aws_lb.fastschema[0].dns_name : null
}

output "alb_zone_id" {
  description = "Route53 zone ID of the ALB (if ALB is enabled)."
  value       = var.enable_alb ? aws_lb.fastschema[0].zone_id : null
}

output "dashboard_url" {
  description = "URL to the FastSchema dashboard (if ALB is enabled)."
  value       = var.enable_alb ? "http://${aws_lb.fastschema[0].dns_name}/dash" : null
}

output "log_group_name" {
  description = "CloudWatch log group for FastSchema tasks."
  value       = aws_cloudwatch_log_group.fastschema.name
}
