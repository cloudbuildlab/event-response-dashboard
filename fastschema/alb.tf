# Application Load Balancer
resource "aws_lb" "fastschema" {
  count               = var.enable_alb ? 1 : 0
  name                = "${var.environment}-fastschema"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.alb[0].id]
  subnets             = var.public_subnet_ids
  tags                = merge(var.tags, { Name = "${var.environment}-fastschema" })
}

resource "aws_lb_target_group" "fastschema" {
  count       = var.enable_alb ? 1 : 0
  name        = "${var.environment}-fastschema"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }
  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/dash"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }
  tags = merge(var.tags, { Name = "${var.environment}-fastschema" })
}

resource "aws_lb_listener" "fastschema" {
  count             = var.enable_alb ? 1 : 0
  load_balancer_arn = aws_lb.fastschema[0].arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fastschema[0].arn
  }
}
