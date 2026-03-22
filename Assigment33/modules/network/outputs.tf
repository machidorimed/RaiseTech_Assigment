# ------------------------------------------------------------#
#  Outputs
# ------------------------------------------------------------#
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "pub_sub_a_id" {
  value = aws_subnet.pub_sub_a.id
}

output "pub_sub_c_id" {
  value = aws_subnet.pub_sub_c.id
}

output "pri_sub_a_id" {
  value = aws_subnet.pri_sub_a.id
}

output "pri_sub_c_id" {
  value = aws_subnet.pri_sub_c.id
}
