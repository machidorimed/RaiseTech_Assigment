data "aws_availability_zones" "available" {}

# ------------------------------------------------------------#
#  Database Subnet Group
# ------------------------------------------------------------#
resource "aws_db_subnet_group" "rdsdb_subnet_group" {
  description = "aws-study-${var.my_env}dbsg"
  name        = "aws-study-${var.my_env}dbsg"
  subnet_ids  = var.subnet_ids
  tags = {
    Name = "aws-study-${var.my_env}dbsg"
  }
}

# ------------------------------------------------------------#
#  RDS Security Group
# ------------------------------------------------------------#
resource "aws_security_group" "rdssg" {
  name        = "aws-study-${var.my_env}rdssg"
  description = "Allow Request from WebServer"
  vpc_id      = var.vpc_id
  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = [var.ec2_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-study-${var.my_env}rdssg"
  }
}

# ------------------------------------------------------------#
#  RDS
# ------------------------------------------------------------#
resource "aws_db_instance" "rds" {
  engine         = var.my_engine
  engine_version = var.my_engine_version
  # シングルAZ
  multi_az       = false
  identifier     = "aws-study-${var.my_env}rds"
  username       = var.database_master_name
  password       = var.database_master_password
  db_name        = var.database_name
  instance_class = var.my_instance_class
  storage_type   = "gp2"
  # ストレージ割り当て
  allocated_storage    = 20
  db_subnet_group_name = aws_db_subnet_group.rdsdb_subnet_group.id
  # パブリック接続不許可
  publicly_accessible = false
  vpc_security_group_ids = [
    aws_security_group.rdssg.id
  ]
  availability_zone = data.aws_availability_zones.available.names[0]
  # 自動バックアップ保有期間
  backup_retention_period = 1
  # DB暗号化
  storage_encrypted = true
  # CloudWatch Logsへのログの有効化
  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
    "general",
    "slowquery"
  ]
  # メジャーバージョンアップグレードを許可
  allow_major_version_upgrade = false
  # マイナーバージョン自動アップグレードの有効化
  auto_minor_version_upgrade = true
  # 削除時の自動バックアップ同時削除許可
  delete_automated_backups = true
  # 削除保護
  deletion_protection = false
  tags = {
    Name = "aws-study-${var.my_env}rds"
  }
}
