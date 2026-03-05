# -----------------------------------------------------------------------------
# SSM Parameter Store (secrets managed by Terraform, task reads from SSM)
# -----------------------------------------------------------------------------
resource "aws_ssm_parameter" "app_key" {
  count = var.fastschema_app_key != "" ? 1 : 0
  name  = "/ecs/${var.environment}-${local.app_name}/APP_KEY"
  type  = "SecureString"
  value = var.fastschema_app_key
  tags  = merge(var.tags, { Name = "/ecs/${var.environment}-${local.app_name}/APP_KEY" })
}

resource "aws_ssm_parameter" "admin_username" {
  count = (var.fastschema_admin_username != "" && var.fastschema_admin_password != "") ? 1 : 0
  name  = "/ecs/${var.environment}-${local.app_name}/ADMIN_USER"
  type  = "String"
  value = var.fastschema_admin_username
  tags  = merge(var.tags, { Name = "/ecs/${var.environment}-${local.app_name}/ADMIN_USER" })
}

resource "aws_ssm_parameter" "admin_password" {
  count = (var.fastschema_admin_username != "" && var.fastschema_admin_password != "") ? 1 : 0
  name  = "/ecs/${var.environment}-${local.app_name}/ADMIN_PASS"
  type  = "SecureString"
  value = var.fastschema_admin_password
  tags  = merge(var.tags, { Name = "/ecs/${var.environment}-${local.app_name}/ADMIN_PASS" })
}
