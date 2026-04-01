data "aws_availability_zones" "available" {}
# ------------------------------------------------------------#
#  VPC
# ------------------------------------------------------------#
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block # v0.12以降の書き方
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "aws-study-${var.my_env}vpc" # 文字列内に変数を埋め込む場合はこの書き方（v0.11形式）
  }
}

# ------------------------------------------------------------#
#  Internet Gateway
# ------------------------------------------------------------#
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "aws-study-${var.my_env}igw"
  }
}

# ------------------------------------------------------------#
#  Route Table
# ------------------------------------------------------------#
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "aws-study-${var.my_env}rtb"
  }
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# ------------------------------------------------------------#
#  Public Sunbet A
# ------------------------------------------------------------#
resource "aws_subnet" "pub_sub_a" {
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pubA_cidr_block
  #サブネット内のEC2のパブリックIPアドレス割り当て
  map_public_ip_on_launch = true
  tags = {
    Name = "aws-study-${var.my_env}pubsub-A"
  }
}

resource "aws_route_table_association" "asso_pub_sub_rt_a" {
  subnet_id      = aws_subnet.pub_sub_a.id
  route_table_id = aws_route_table.route_table.id
}

# ------------------------------------------------------------#
#  Private Sunbet A
# ------------------------------------------------------------#
resource "aws_subnet" "pri_sub_a" {
  availability_zone       = data.aws_availability_zones.available.names[0]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.priA_cidr_block
  map_public_ip_on_launch = false
  tags = {
    Name = "aws-study-${var.my_env}prisub-A"
  }
}

# ------------------------------------------------------------#
#  Public Sunbet C
# ------------------------------------------------------------#
resource "aws_subnet" "pub_sub_c" {
  availability_zone       = data.aws_availability_zones.available.names[1]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pubC_cidr_block
  map_public_ip_on_launch = true
  tags = {
    Name = "aws-study-${var.my_env}pubsub-C"
  }
}

resource "aws_route_table_association" "asso_pub_sub_rt_c" {
  subnet_id      = aws_subnet.pub_sub_c.id
  route_table_id = aws_route_table.route_table.id
}


# ------------------------------------------------------------#
#  Private Sunbet C
# ------------------------------------------------------------#
resource "aws_subnet" "pri_sub_c" {
  availability_zone       = data.aws_availability_zones.available.names[1]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.priC_cidr_block
  map_public_ip_on_launch = false
  tags = {
    Name = "aws-study-${var.my_env}prisub-C"
  }
}
