terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Permite Postgres solo desde el SG de la instancia de la app"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres desde la instancia de la app"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_instance_sg_id]
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_db_instance" "this" {
  identifier     = "${var.project_name}-db"
  engine         = "postgres"
  engine_version = "16.15"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible        = false
  skip_final_snapshot        = true
  deletion_protection        = false
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  tags = {
    Project = var.project_name
  }
}
