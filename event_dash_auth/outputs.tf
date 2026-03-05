# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "web_url" {
  description = "URL to the Go web app (event response dashboard with Cognito auth)."
  value       = "https://${aws_lb.app.dns_name}"
}

output "log_group_fastschema" {
  value = aws_cloudwatch_log_group.fastschema.name
}

output "log_group_web" {
  value = aws_cloudwatch_log_group.web.name
}

output "cognito_user_pool_id" {
  description = "Cognito user pool ID."
  value       = aws_cognito_user_pool.this.id
}

output "cognito_user_pool_domain" {
  description = "Cognito hosted UI domain prefix."
  value       = aws_cognito_user_pool_domain.this.domain
}
