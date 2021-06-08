# LB instance health check 
resource "aws_cloudwatch_metric_alarm" "lb_healthy_hosts_less_than_one" {
  alarm_name          = "${local.common_name}_JitBit_lb_unhealthy_hosts_count--critical"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "No Healthy Hosts!!! JitBit Application is down"
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    TargetGroup  = local.jitbit["aws_lb_target_group_arn_suffix"]
    LoadBalancer = local.jitbit["aws_lb_arn_suffix"]
  }

  tags = local.tags
}
