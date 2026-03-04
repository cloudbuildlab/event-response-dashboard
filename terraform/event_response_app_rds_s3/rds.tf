# -----------------------------------------------------------------------------
# RDS (PostgreSQL) - fully managed
# -----------------------------------------------------------------------------

resource "aws_db_subnet_group" "app" {
  name        = "${var.environment}-${local.app_name}"
  description = "DB subnet group for ${local.app_name}"
  subnet_ids  = var.private_subnet_ids
  tags        = merge(var.tags, { Name = "${var.environment}-${local.app_name}" })
}

resource "aws_security_group" "rds" {
  name        = "${var.environment}-${local.app_name}-rds"
  description = "RDS PostgreSQL for ${local.app_name}; allow ECS tasks only"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.environment}-${local.app_name}-rds" })
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.tasks.id]
    description     = "PostgreSQL from ECS tasks"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_password" "rds" {
  length           = 32
  override_special = "!#$%&*()-_=+[]{}<>:?"
  special          = true
}

resource "aws_db_instance" "this" {
  identifier     = "${var.environment}-${local.app_name}"
  engine         = "postgres"
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class
  allocated_storage     = var.rds_allocated_storage
  storage_type         = "gp3"
  db_name              = var.rds_database_name
  username             = var.rds_master_username
  password             = random_password.rds.result
  db_subnet_group_name   = aws_db_subnet_group.app.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az              = var.rds_multi_az
  skip_final_snapshot    = true
  deletion_protection    = false
  tags                   = merge(var.tags, { Name = "${var.environment}-${local.app_name}" })
}
