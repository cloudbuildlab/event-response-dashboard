# -----------------------------------------------------------------------------
# IAM Roles for ECS
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ecs_execution" {
  name = "${var.environment}-${local.app_name}-ecs-execution"
  tags = merge(var.tags, { Name = "${var.environment}-${local.app_name}-ecs-execution" })
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_execution_ssm" {
  count = (var.fastschema_app_key != "" || (var.fastschema_admin_username != "" && var.fastschema_admin_password != "") || (var.rds_endpoint != "" && var.rds_password != "")) ? 1 : 0
  statement {
    effect = "Allow"
    actions = ["ssm:GetParameter", "ssm:GetParameters"]
    resources = concat(
      var.fastschema_app_key != "" ? [aws_ssm_parameter.app_key[0].arn] : [],
      (var.fastschema_admin_username != "" && var.fastschema_admin_password != "") ? [
        aws_ssm_parameter.admin_username[0].arn,
        aws_ssm_parameter.admin_password[0].arn
      ] : [],
      (var.rds_endpoint != "" && var.rds_password != "") ? [aws_ssm_parameter.rds_password[0].arn] : []
    )
  }
}

resource "aws_iam_role_policy" "ecs_execution_ssm" {
  count  = (var.fastschema_app_key != "" || (var.fastschema_admin_username != "" && var.fastschema_admin_password != "") || (var.rds_endpoint != "" && var.rds_password != "")) ? 1 : 0
  name   = "${var.environment}-${local.app_name}-ssm"
  role   = aws_iam_role.ecs_execution.id
  policy = data.aws_iam_policy_document.ecs_execution_ssm[0].json
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.environment}-${local.app_name}-ecs-task"
  tags = merge(var.tags, { Name = "${var.environment}-${local.app_name}-ecs-task" })
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

data "aws_iam_policy_document" "ecs_task_s3" {
  count = var.s3_bucket_name != "" ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }
}

resource "aws_iam_role_policy" "ecs_task_s3" {
  count  = var.s3_bucket_name != "" ? 1 : 0
  name   = "${var.environment}-${local.app_name}-s3"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_task_s3[0].json
}
