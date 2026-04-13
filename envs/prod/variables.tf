# ------------------------------------------------------------#
# 変数定義
# ------------------------------------------------------------#
# defaultは記述しないでもOK。記述がある場合は、変数に値を設定しない場合にdefault値が適用される
variable "my_env" {
  type = string
}

# 変数一覧(network)
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "pubA_cidr_block" {
  type = string
}

variable "priA_cidr_block" {
  type = string
}

variable "pubC_cidr_block" {
  type = string
}

variable "priC_cidr_block" {
  type = string
}

# 変数一覧(compute)
variable "my_ip" {
  description = "IP address allowed to access EC2"
  type        = string
}

variable "my_ami" {
  type = string
}

variable "my_instance_type" {
  type = string
}

# 変数一覧(database)
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

# 変数一覧(monitoring)
variable "my_email" {
  description = "Email address from SNS Topic"
  type        = string
}

# 変数一覧(security)
variable "allow_ip_addresses" {
  description = "Whitelist for Enter IP adress"
  type        = list(string)

}
