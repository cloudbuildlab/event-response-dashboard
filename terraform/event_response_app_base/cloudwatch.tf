# -----------------------------------------------------------------------------
# CloudWatch Logs
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "fastschema" {
  name              = "/ecs/${var.environment}-${local.app_name}-fastschema"
  retention_in_days = 1
  skip_destroy      = false
  tags              = merge(var.tags, { Name = "/ecs/${var.environment}-${local.app_name}-fastschema" })
}

resource "aws_cloudwatch_log_group" "web" {
  name              = "/ecs/${var.environment}-${local.app_name}-web"
  retention_in_days = 1
  skip_destroy      = false
  tags              = merge(var.tags, { Name = "/ecs/${var.environment}-${local.app_name}-web" })
}
