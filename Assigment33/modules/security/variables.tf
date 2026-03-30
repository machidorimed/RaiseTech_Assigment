# ------------------------------------------------------------#
# 変数定義
# ------------------------------------------------------------#
# defaultは記述しないでもOK。記述がある場合は、変数に値を設定しない場合にdefault値が適用される
variable "my_env" {
  type = string
}

variable "allow_ip_addresses" {
  description = "Whitelist for Enter IP adress"
  type        = list(string)

}

variable "alb_arn" {
  type = string
}

variable "log_group_arn" {
  type = string
}
