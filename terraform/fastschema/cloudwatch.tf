# -----------------------------------------------------------------------------
# CloudWatch Logs
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "fastschema" {
  name              = "/ecs/${var.environment}-fastschema"
  retention_in_days = 1
  skip_destroy      = false

  tags = merge(var.tags, { Name = "/ecs/${var.environment}-fastschema" })
}
