# ------------------------------------------------------------#
#  Outputs
# ------------------------------------------------------------#
output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.rds.address
}
