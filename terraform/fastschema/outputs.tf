output "dashboard_url" {
  description = "URL to the FastSchema dashboard (if ALB is enabled)."
  value       = var.enable_alb ? "http://${aws_lb.fastschema[0].dns_name}/dash" : null
}

output "log_group_name" {
  description = "CloudWatch log group for FastSchema tasks."
  value       = aws_cloudwatch_log_group.fastschema.name
}
