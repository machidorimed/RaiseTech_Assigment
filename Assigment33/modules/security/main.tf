# ------------------------------------------------------------#
#  AWS WAF v2
# ------------------------------------------------------------#
resource "aws_wafv2_web_acl" "web_acl" {
  name        = "aws-study-${var.my_env}alb-waf"
  description = "Web ACL for InternetALB"
  scope       = "REGIONAL"
  default_action {
    block {}
  }

  ## 指定したIPアドレスからのアクセスを許可する
  rule {
    name     = "IPAddressWhitelistRule"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ip_whitelist.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPAddressWhitelistRule"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "aws-study-${var.my_env}alb-waf"
    sampled_requests_enabled   = true
  }
}

# ------------------------------------------------------------#
#  White IP Address
# ------------------------------------------------------------#
resource "aws_wafv2_ip_set" "ip_whitelist" {
  name               = "IPAddressWhitelist-${var.my_env}"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.allow_ip_addresses
}

# ------------------------------------------------------------#
#  WebACL Association
# ------------------------------------------------------------#
resource "aws_wafv2_web_acl_association" "web_acl_association" {
  ## WAF と ALB を連携する設定。
  ## WAF と CloudFront 連携時は不要。
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
}

# ------------------------------------------------------------#
#  WAFv2 Log Config
# ------------------------------------------------------------#
resource "aws_wafv2_web_acl_logging_configuration" "waf_logs_config" {
  # ログデータの送信先
  log_destination_configs = [var.log_group_arn]
  # ログデータを出力するWAFのARN
  resource_arn = aws_wafv2_web_acl.web_acl.arn
}
