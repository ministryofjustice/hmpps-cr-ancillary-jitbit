# IIS HttpErr log Metrics
# Note: Metrics wont be created unless an entry exists on the first time deployment
resource "aws_cloudwatch_log_metric_filter" "iis_httperr_metrics" {
  name           = "${local.common_name}_IIS_AppPool"
  pattern        = "AppOffline"
  log_group_name = local.common_name

  metric_transformation {
    name          = "${local.common_name}_AppPool"
    namespace     = "IIS"
    value         = 1
    default_value = 0
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

# Endpoint HealthCheck using Route53
resource "aws_route53_health_check" "jitbit" {
  fqdn              = local.jitbit["aws_route53_record_name"]
  port              = 443
  type              = "HTTPS"
  resource_path     = "/User/Login"
  failure_threshold = 3
  request_interval  = 30
  regions           = ["us-east-1", "eu-west-1", "ap-southeast-1"]
  tags              = local.tags
}

resource "aws_cloudwatch_metric_alarm" "jitbit" {
  alarm_name          = "${local.common_name}_jitbit_endpoint_status--critical"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "Route53 health check status for ${local.jitbit["aws_route53_record_name"]}"
  # alarm_actions       = [local.sns_alarm_notification_arn]
  # ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    HealthCheckId = aws_route53_health_check.jitbit.id
  }

  tags                = local.tags
}
