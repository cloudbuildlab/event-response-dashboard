# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "web_url" {
  description = "URL to the Go web app (event response dashboard with RDS and S3)."
  value       = "http://${aws_lb.app.dns_name}"
}

output "log_group_fastschema" {
  value = aws_cloudwatch_log_group.fastschema.name
}

output "log_group_web" {
  value = aws_cloudwatch_log_group.web.name
}

output "rds_endpoint" {
  description = "RDS instance endpoint (host:port)."
  value       = aws_db_instance.this.endpoint
}

output "rds_database_name" {
  description = "Name of the RDS database."
  value       = aws_db_instance.this.db_name
}

output "s3_bucket_name" {
  description = "Name of the managed S3 bucket."
  value       = aws_s3_bucket.app.id
}
