# ------------------------------------------------------------#
#  ALB Security Group
# ------------------------------------------------------------#
resource "aws_security_group" "albsg" {
  name        = "aws-study-${var.my_env}albsg"
  description = "Allow HTTP access from internet"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-study-${var.my_env}albsg"
  }
}

# ------------------------------------------------------------#
#  ALB 
# ------------------------------------------------------------#
resource "aws_lb" "alb" {
  name               = "aws-study-${var.my_env}alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.albsg.id]

  subnets         = var.public_subnet_ids
  ip_address_type = "ipv4"

  tags = {
    Name = "aws-study-${var.my_env}alb"
  }
}

# ------------------------------------------------------------#
#  Target Group
# ------------------------------------------------------------#
resource "aws_lb_target_group" "albtg" {
  name             = "aws-study-${var.my_env}tg"
  target_type      = "instance"
  protocol_version = "HTTP1"
  port             = 8080
  protocol         = "HTTP"

  vpc_id = var.vpc_id

  tags = {
    Name = "aws-study-${var.my_env}tg"
  }

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200,300,301"
  }
}

resource "aws_lb_target_group_attachment" "test_target_ec2" {
  target_group_arn = aws_lb_target_group.albtg.arn
  target_id        = aws_instance.ec2.id
}

# ------------------------------------------------------------#
#  ALB Listner
# ------------------------------------------------------------#
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.albtg.arn
  }
}

# ------------------------------------------------------------#
#  EC2 Security Group
# ------------------------------------------------------------#
resource "aws_security_group" "ec2_sg" {
  description = "Allow SSH and HTTP and Springboot from Internet"
  vpc_id      = var.vpc_id

  # App only access from alb
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.albsg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-study-${var.my_env}ec2sg"
  }
}

# ------------------------------------------------------------#
#  EC2
# ------------------------------------------------------------#
resource "aws_instance" "ec2" {
  ami           = var.my_ami
  instance_type = var.my_instance_type
  # セッションマネージャー用IAMロール
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  # 削除保護
  disable_api_termination = false
  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }
  tags = {
    Name = "aws-study-${var.my_env}ec2"
  }
}

# ------------------------------------------------------------#
#  AWS Systems Manager Session Manager IAM Role
# ------------------------------------------------------------#
resource "aws_iam_role" "ssm_role" {
  name = "aws-study-${var.my_env}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "s3_fullaccess_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "aws-study-${var.my_env}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}
