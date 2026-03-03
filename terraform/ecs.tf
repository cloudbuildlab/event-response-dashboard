# -----------------------------------------------------------------------------
# ECS Task Definition and Service
# -----------------------------------------------------------------------------
locals {
  container_definitions = [
    {
      name      = "fastschema"
      image     = var.fastschema_image
      essential = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"        = aws_cloudwatch_log_group.fastschema.name
          "awslogs-region"       = data.aws_region.current.id
          "awslogs-stream-prefix" = "ecs"
        }
      }

      environment = []
      secrets     = var.app_key_secret_arn != "" ? [{ name = "APP_KEY", valueFrom = var.app_key_secret_arn }] : []

      healthCheck = {
        command     = ["CMD-SHELL", "nc -z localhost 8000 || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ]
}

resource "aws_ecs_task_definition" "fastschema" {
  family                   = "fastschema-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode(local.container_definitions)
}

resource "aws_ecs_service" "fastschema" {
  name            = "fastschema-${var.environment}"
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.fastschema.arn
  desired_count   = var.desired_count
  launch_type     = "EC2"

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
      container_port   = 8000
    }
  }
}
