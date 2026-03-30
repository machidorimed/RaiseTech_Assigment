# ------------------------------------------------------------#
# 変数定義
# ------------------------------------------------------------#
# defaultは記述しないでもOK。記述がある場合は、変数に値を設定しない場合にdefault値が適用される
variable "my_env" {}

variable "instance_id" {
  type = string
}

variable "my_email" {
  description = "Email address from SNS Topic"
  type        = string
}
