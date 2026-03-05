# -----------------------------------------------------------------------------
# Local values
# -----------------------------------------------------------------------------
locals {
  my_public_ip_cidr = "${trimspace(data.http.my_public_ip.response_body)}/32"
  app_name          = "event-dash-external"
  name              = "${var.environment}-${local.app_name}-${data.aws_caller_identity.current.account_id}"

  s3_bucket_name = "${local.name}-${random_id.s3_suffix.hex}"

  # FastSchema database (RDS) and storage (S3) config per https://fastschema.com/docs/configuration.html
  # RDS requires SSL (pg_hba.conf); PGSSLMODE=require so client uses TLS.
  fastschema_db_env = [
    { name = "DB_DRIVER", value = "pgx" },
    { name = "DB_NAME", value = aws_db_instance.this.db_name },
    { name = "DB_HOST", value = aws_db_instance.this.address },
    { name = "DB_PORT", value = tostring(aws_db_instance.this.port) },
    { name = "DB_USER", value = aws_db_instance.this.username },
    { name = "PGSSLMODE", value = "require" }
  ]
  # Storage uses rclone; provider "AWS" (uppercase) per rclone S3 backend.
  fastschema_storage_env = [
    { name = "STORAGE", value = jsonencode({
      default_disk = "s3"
      disks = [{
        name     = "s3"
        driver   = "s3"
        provider = "AWS"
        bucket   = local.s3_bucket_name
        region   = data.aws_region.current.region
      }]
    }) }
  ]

  fastschema_container = merge(
    {
      name      = "fastschema"
      image     = var.fastschema_image
      essential = true
      portMappings = [{
        containerPort = var.app_port
        hostPort      = var.app_port
        protocol      = "tcp"
        appProtocol   = "http"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.fastschema.name
          "awslogs-region"        = data.aws_region.current.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = concat(
        local.fastschema_db_env,
        local.fastschema_storage_env,
        var.fastschema_event_schema_b64 != "" ? [{ name = "SCHEMA_EVENT_B64", value = var.fastschema_event_schema_b64 }] : []
      )
      secrets = concat(
        var.fastschema_app_key != "" ? [{ name = "APP_KEY", valueFrom = aws_ssm_parameter.app_key[0].arn }] : [],
        (var.fastschema_admin_username != "" && var.fastschema_admin_password != "") ? [
          { name = "ADMIN_USER", valueFrom = aws_ssm_parameter.admin_username[0].arn },
          { name = "ADMIN_PASS", valueFrom = aws_ssm_parameter.admin_password[0].arn }
        ] : [],
        [{ name = "DB_PASS", valueFrom = aws_ssm_parameter.rds_password.arn }]
      )
      healthCheck = {
        command     = ["CMD-SHELL", "wget -q --spider http://127.0.0.1:${var.app_port}/dash || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    },
    (var.fastschema_event_schema_b64 != "" || (var.fastschema_admin_username != "" && var.fastschema_admin_password != "")) ? {
      command = ["/bin/sh", "-c", "mkdir -p /fastschema/data/schemas && if [ -n \"$SCHEMA_EVENT_B64\" ]; then echo \"$SCHEMA_EVENT_B64\" | base64 -d > /fastschema/data/schemas/event.json; fi && if [ -n \"$ADMIN_USER\" ] && [ -n \"$ADMIN_PASS\" ]; then /fastschema/fastschema setup -u \"$ADMIN_USER\" -p \"$ADMIN_PASS\" . || true; fi && exec /fastschema/fastschema start ."]
    } : {}
  )

  web_container = {
    name      = "web"
    image     = var.web_image
    essential = true
    dependsOn = [{ containerName = "fastschema", condition = "HEALTHY" }]
    portMappings = [{
      containerPort = var.web_port
      hostPort      = var.web_port
      protocol      = "tcp"
      appProtocol   = "http"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.web.name
        "awslogs-region"        = data.aws_region.current.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
    environment = [
      { name = "FASTSCHEMA_URL", value = "http://localhost:8000" },
      { name = "PORT", value = tostring(var.web_port) }
    ]
    secrets = (var.fastschema_admin_username != "" && var.fastschema_admin_password != "") ? [
      { name = "FASTSCHEMA_ADMIN_USER", valueFrom = aws_ssm_parameter.admin_username[0].arn },
      { name = "FASTSCHEMA_ADMIN_PASS", valueFrom = aws_ssm_parameter.admin_password[0].arn }
    ] : []
    healthCheck = {
      command     = ["CMD-SHELL", "wget -q --spider http://127.0.0.1:${var.web_port}/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }

  container_definitions = [local.fastschema_container, local.web_container]
}
