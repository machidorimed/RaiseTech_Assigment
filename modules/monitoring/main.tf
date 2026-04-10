# ------------------------------------------------------------#
#  CloudWatch Alarm
# ------------------------------------------------------------#
#resource "aws_cloudwatch_metric_alarm" "ec2_cpu_utilization_alarm" {
### 基本設定
#  alarm_name        = "aws-study-${var.my_env}-cpu-utilization-alarm"
#  alarm_description = "aws-study-${var.my_env}ec2 の 60 秒間の 平均 CPU使用率が 0.1 %以上になりました。 SNSに通知します"

### メトリクス
#  namespace = "AWS/EC2"
#  dimensions = {
#    InstanceId = var.instance_id
#  }
#  metric_name = "CPUUtilization"
#  unit        = "Percent"

### 統計
#  period    = 60
#  statistic = "Average"

### 評価
#  threshold = 0.1
# 比較に用いる算術演算
#  comparison_operator = "GreaterThanOrEqualToThreshold"
# 評価する期間の数
#  evaluation_periods = 1
# 「しきい値超過」の数
#  datapoints_to_alarm = 1
#  treat_missing_data  = "missing"

### アクション
#  actions_enabled = true
#  alarm_actions = [
#    aws_sns_topic.sns_topic.id
#  ]
#}

# ------------------------------------------------------------#
#  Amazon SNS Topic
# ------------------------------------------------------------#
#resource "aws_sns_topic" "sns_topic" {
#  name = "aws-study-${var.my_env}-topic"
#  tags = {
#    Name = "aws-study-${var.my_env}-topic"
#  }
#}

# ------------------------------------------------------------#
#  E-mail Subscription
# ------------------------------------------------------------#
#resource "aws_sns_topic_subscription" "alarm_email_subscription" {
#  topic_arn = aws_sns_topic.sns_topic.arn
#  protocol  = "email"
#  endpoint  = var.my_email
#}

# ------------------------------------------------------------#
#  CloudWatch Logs Log Group (WAFv2)
# ------------------------------------------------------------#
#resource "aws_cloudwatch_log_group" "waf_log_group" {
# 必ずaws-waf-logs-から始まる名前にすること!
#  name = "aws-waf-logs-study-${var.my_env}alb"
# ログ保存期間
#  retention_in_days = 30
#  tags = {
#    Name = "aws-waf-logs-study-${var.my_env}alb"
#  }
#}

# ------------------------------------------------------------#
#  CloudWatch Logs Resource Policy
# ------------------------------------------------------------#
#data "aws_iam_policy_document" "waf_logs" {
## CloudWatch Logs に自分のアカウントの WAF サービスに対して 
## WAFLogGroup の全ログストリームの作成とログ書き込みを
## 許可するリソースベースポリシーを付与する。
#  statement {
#    sid = "AWSWAF-${var.my_env}Logs"

#    actions = [
#      "logs:CreateLogStream",
#      "logs:PutLogEvents"
#    ]

#    principals {
#      identifiers = ["delivery.logs.amazonaws.com"]
#      type        = "Service"
#    }

#    resources = ["*"]
#  }
#}

#resource "aws_cloudwatch_log_resource_policy" "waf_log_resource_policy" {
#  policy_document = data.aws_iam_policy_document.waf_logs.json
#  policy_name     = "waf-log-${var.my_env}policy"
#}

# ------------------------------------------------------------#
#  S3 bucket
# ------------------------------------------------------------#
resource "aws_s3_bucket" "s3" {
  bucket = "aws-study-ansible-${var.my_env}-marube23-bucket"
}

resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = aws_s3_bucket.s3.id
  versioning_configuration {
    status = "Enabled"
  }
}
