# IIS HttpErr log Metrics
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
resource "aws_cloudwatch_metric_alarm" "iis_httperr" {
  alarm_name                = "${local.common_name}_AppPool_Offline"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "${local.common_name}_AppPool"
  namespace                 = "IIS"
  period                    = "60"
  statistic                 = "SampleCount"
  threshold                 = "0"
  alarm_description         = "This metric monitors IIS HttpErr"

#   alarm_actions       = [aws_sns_topic.alarm_notification.arn]
#   ok_actions          = [aws_sns_topic.alarm_notification.arn]
}

# General Instance check 
