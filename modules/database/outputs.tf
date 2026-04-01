# ------------------------------------------------------------#
#  Outputs
# ------------------------------------------------------------#
output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.rds.address
}

#terraform test用
output "rds_instance_summary" {
  value = {
    engine         = aws_db_instance.rds.engine
    engine_version = aws_db_instance.rds.engine_version
    instance_class = aws_db_instance.rds.instance_class
  }
}
