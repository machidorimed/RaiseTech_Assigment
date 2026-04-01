# ------------------------------------------------------------#
# 変数定義
# ------------------------------------------------------------#
# defaultは記述しないでもOK。記述がある場合は、変数に値を設定しない場合にdefault値が適用される
variable "my_env" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "ec2_sg_id" {
  type = string
}

variable "my_engine" {
  type = string
}

variable "my_engine_version" {
  type = string
}

variable "database_master_name" {
  description = "Database Master User Name"
  type        = string
}

variable "database_master_password" {
  description = "Database Master User Password"
  type        = string
  sensitive   = true
}

variable "my_instance_class" {
  type = string
}

variable "database_name" {
  description = "Database Name"
  type        = string
}
