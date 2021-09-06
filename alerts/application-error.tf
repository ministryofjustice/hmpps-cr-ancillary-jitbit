# Application Error log Metrics
resource "aws_cloudwatch_log_metric_filter" "application_error_metrics" {
  name           = "${local.common_name}_Application_Error"
  pattern        = "Error in Helpdesk"
  log_group_name = local.common_name

  metric_transformation {
    name          = "${local.common_name}_Application_Error"
    namespace     = "JitBit"
    value         = 1
    default_value = 0
  }
}

# Application Error Alarm
resource "aws_cloudwatch_metric_alarm" "application_error_critical" {
  alarm_name          = "${local.common_name}_Application_Error--critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "${local.common_name}_Application_Error"
  namespace           = "JitBit"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "This metric monitors Application Functionality Error E:g. Mailbox failure, It would be either on Blue or Green Stack"
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]
  tags                = local.tags
}
