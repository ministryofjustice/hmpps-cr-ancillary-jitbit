# IIS HttpErr log Metrics
# Note: Metrics wont be created unless an entry exists on the first time deployment
resource "aws_cloudwatch_log_metric_filter" "iis_httperr_metrics" {
  name           = "${local.common_name}_IIS_AppPool"
  pattern        = "AppOffline"
  log_group_name = local.common_name

  metric_transformation {
    name      = "${local.common_name}_AppPool"
    namespace = "IIS"
    value     = "1"
  }
}

# IIS HttpErr Alarm
# Alarm remains in Insufficent data as metrics not created until first time
resource "aws_cloudwatch_metric_alarm" "iis_httperr" {
  alarm_name          = "${local.common_name}_AppPool_Offline--critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "${local.common_name}_AppPool"
  namespace           = "IIS"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "0"
  alarm_description   = "This metric monitors IIS HttpErr"
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]
  tags                = local.tags
}
