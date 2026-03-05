# -----------------------------------------------------------------------------
# Security Groups (VPC-scoped networking)
# -----------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  count       = var.enable_alb ? 1 : 0
  name        = "${var.environment}-fastschema-alb"
  description = "ALB for FastSchema"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.environment}-fastschema-alb" })

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.my_public_ip_cidr]
    description = "HTTP from deployer IP only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tasks" {
  name        = "${var.environment}-fastschema-tasks"
  description = "FastSchema ECS tasks"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.environment}-fastschema-tasks" })

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = var.enable_alb ? [aws_security_group.alb[0].id] : []
    cidr_blocks     = var.enable_alb ? [] : ["0.0.0.0/0"]
    description     = "FastSchema app port"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
