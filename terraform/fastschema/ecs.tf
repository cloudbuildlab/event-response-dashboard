# -----------------------------------------------------------------------------
# ECS Task Definition and Service
# -----------------------------------------------------------------------------
resource "aws_ecs_task_definition" "fastschema" {
  family                   = "${var.environment}-fastschema"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  tags                     = merge(var.tags, { Name = "${var.environment}-fastschema" })

  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode(local.container_definitions)
}

resource "aws_ecs_service" "fastschema" {
  name            = "${var.environment}-fastschema"
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.fastschema.arn
  desired_count   = var.desired_count
  launch_type     = "EC2"
  tags            = merge(var.tags, { Name = "${var.environment}-fastschema" })
  depends_on      = [aws_lb_listener.fastschema]

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.tasks.id]
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = var.enable_alb ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.fastschema[0].arn
      container_name   = "fastschema"
      container_port   = var.app_port
    }
  }
}
