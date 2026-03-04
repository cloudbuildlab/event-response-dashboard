output "web_url" {
  description = "URL to the Go web app (event response dashboard)."
  value       = "http://${aws_lb.app.dns_name}"
}

output "log_group_fastschema" {
  value = aws_cloudwatch_log_group.fastschema.name
}

output "log_group_web" {
  value = aws_cloudwatch_log_group.web.name
}
