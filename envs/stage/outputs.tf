# ------------------------------------------------------------#
#  Outputs
# ------------------------------------------------------------#
output "ec2_public_ip" {
  value = module.compute.ec2_public_ip
}

output "instance_id" {
  value = module.compute.instance_id
}
