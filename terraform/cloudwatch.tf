# -----------------------------------------------------------------------------
# CloudWatch Logs
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "fastschema" {
  name             = "/ecs/fastschema-${var.environment}"
  retention_in_days = 7
}
