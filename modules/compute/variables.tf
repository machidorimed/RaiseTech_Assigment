# ------------------------------------------------------------#
# 変数定義
# ------------------------------------------------------------#
# defaultは記述しないでもOK。記述がある場合は、変数に値を設定しない場合にdefault値が適用される
variable "my_env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "public_subnet_id" {
  type = string
}

variable "my_ip" {
  description = "IP address allowed to access EC2"
}

variable "my_ami" {
  type = string
}

variable "my_instance_type" {
  type = string
}
