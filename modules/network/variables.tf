# ------------------------------------------------------------#
# 変数定義
# ------------------------------------------------------------#
# defaultは記述しないでもOK。記述がある場合は、変数に値を設定しない場合にdefault値が適用される
variable "my_env" {
  type = string
}

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
