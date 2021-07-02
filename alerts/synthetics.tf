# Endpoint failure
resource "aws_cloudwatch_metric_alarm" "synthetics_failed_requests" {
  alarm_name          = "${local.common_name}_synthetics_failed_request_endpoint--critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Failed requests"
  namespace           = "CloudWatchSynthetics"
  period              = "3600"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "Synthetics report on endpoint requests"
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    CanaryName = local.common_name
  }

  tags = local.tags
}

# 4xx
resource "aws_cloudwatch_metric_alarm" "synthetics_4xx" {
  alarm_name          = "${local.common_name}_synthetics_error_responses-4xx--warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "4xx"
  namespace           = "CloudWatchSynthetics"
  period              = "3600"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "Synthetics report on Error Responses 4xx"
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    CanaryName = local.common_name
  }

  tags = local.tags
}

# 5xx
resource "aws_cloudwatch_metric_alarm" "synthetics_5xx" {
  alarm_name          = "${local.common_name}_synthetics_fault_responses_5xx--warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "5xx"
  namespace           = "CloudWatchSynthetics"
  period              = "3600"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "Synthetics report on Fault Responses 5xx"
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    CanaryName = local.common_name
  }

  tags = local.tags
}

# Failure on execution of Cananry   
resource "aws_cloudwatch_metric_alarm" "synthetics_Cananry" {
  alarm_name          = "${local.common_name}_synthetics_canary_failure--warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Failed"
  namespace           = "CloudWatchSynthetics"
  period              = "3600"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "Alert on Synthetics Cananry execution failure"
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    CanaryName = local.common_name
  }

  tags = local.tags
}
