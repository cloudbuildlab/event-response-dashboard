# -----------------------------------------------------------------------------
# Security Groups (VPC-scoped networking)
# -----------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.environment}-${local.app_name}-alb"
  description = "ALB for ${local.app_name}"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.environment}-${local.app_name}-alb" })
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
  name        = "${var.environment}-${local.app_name}-tasks"
  description = "ECS tasks (FastSchema + web)"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.environment}-${local.app_name}-tasks" })
  ingress {
    from_port       = var.web_port
    to_port         = var.web_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Web app from ALB"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
