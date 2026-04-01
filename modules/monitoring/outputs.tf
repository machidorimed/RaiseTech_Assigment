# ------------------------------------------------------------#
#  Outputs
# ------------------------------------------------------------#
output "waf_log_group_arn" {
  description = "WAF LogGroup ARN"
  value       = aws_cloudwatch_log_group.waf_log_group.arn
}

output "sns_topic_arn" {
  description = "SNS Topic ARN"
  value       = aws_sns_topic.sns_topic.arn
}

output "waf_log_group_id" {
  value = aws_cloudwatch_log_group.waf_log_group.id
}
