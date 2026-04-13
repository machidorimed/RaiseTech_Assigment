# ------------------------------------------------------------#
#  Outputs
# ------------------------------------------------------------#
output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}

output "instance_id" {
  value = aws_instance.ec2.id
}

output "albdns_name" {
  description = "ALB DNS Name"
  value       = aws_lb.alb.dns_name
}

output "alb_arn" {
  value = aws_lb.alb.arn
}

#terraform test用
output "ec2_instance_type" {
  value = aws_instance.ec2.instance_type
}

# ansible用
output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}
