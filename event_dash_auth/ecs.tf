# -----------------------------------------------------------------------------
# ECS Task Definition and Service
# -----------------------------------------------------------------------------
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.environment}-${local.app_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "512"
  memory                   = "1024"
  tags                     = merge(var.tags, { Name = "${var.environment}-${local.app_name}" })
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  container_definitions    = jsonencode(local.container_definitions)
}

resource "aws_ecs_service" "app" {
  name            = "${var.environment}-${local.app_name}"
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "EC2"
  tags            = merge(var.tags, { Name = "${var.environment}-${local.app_name}" })
  depends_on      = [aws_lb_listener.app, aws_lb_listener.https]
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.tasks.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.web.arn
    container_name   = "web"
    container_port   = var.web_port
  }
}
