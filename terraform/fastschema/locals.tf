# -----------------------------------------------------------------------------
# Local values
# -----------------------------------------------------------------------------
locals {
  container_definitions = [
    merge(
      {
        name      = "fastschema"
        image     = var.fastschema_image
        essential = true

        portMappings = [
          {
            containerPort = var.app_port
            hostPort      = var.app_port
            protocol      = "tcp"
            appProtocol   = "http"
          }
        ]

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = aws_cloudwatch_log_group.fastschema.name
            "awslogs-region"        = data.aws_region.current.region
            "awslogs-stream-prefix" = "ecs"
          }
        }

        environment = []
        secrets = concat(
          var.fastschema_app_key != "" ? [{ name = "APP_KEY", valueFrom = aws_ssm_parameter.app_key[0].arn }] : [],
          (var.fastschema_admin_username != "" && var.fastschema_admin_password != "") ? [
            { name = "ADMIN_USER", valueFrom = aws_ssm_parameter.admin_username[0].arn },
            { name = "ADMIN_PASS", valueFrom = aws_ssm_parameter.admin_password[0].arn }
          ] : []
        )

        healthCheck = {
          command     = ["CMD-SHELL", "wget -q --spider http://127.0.0.1:${var.app_port}/dash || exit 1"]
          interval    = 30
          timeout     = 5
          retries     = 3
          startPeriod = 60
        }
      },
      # When admin credentials are provided, run `fastschema setup` on first boot
      # before `start`. The setup CLI is the only way to create the admin user —
      # FastSchema has no ADMIN_USER/ADMIN_PASS env var support. On subsequent
      # restarts with a populated DB the setup call fails with "user already
      # exists" which `|| true` suppresses so start proceeds normally.
      # Note: do NOT use ${...} bash syntax here; Terraform treats ${ as its own
      # interpolation. Use plain $VAR (no braces) for shell variable references.
      (var.fastschema_admin_username != "" && var.fastschema_admin_password != "") ? {
        command = [
          "/bin/sh", "-c",
          "if [ -n \"$ADMIN_USER\" ] && [ -n \"$ADMIN_PASS\" ]; then /fastschema/fastschema setup -u \"$ADMIN_USER\" -p \"$ADMIN_PASS\" . || true; fi; exec /fastschema/fastschema start ."
        ]
      } : {}
    )
  ]
}
