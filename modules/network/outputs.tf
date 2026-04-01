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

#terraform test用
output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnets" {
  value = {
    a_cidr = aws_subnet.pub_sub_a.cidr_block
    c_cidr = aws_subnet.pub_sub_c.cidr_block
  }
}

output "private_subnets" {
  value = {
    a_cidr = aws_subnet.pri_sub_a.cidr_block
    c_cidr = aws_subnet.pri_sub_c.cidr_block
  }
}
