# LB instance health check 
resource "aws_cloudwatch_metric_alarm" "lb_healthy_hosts_less_than_one" {
  alarm_name          = "${local.common_name}_JitBit_lb_unhealthy_hosts_count--critical"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ELB"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "No Healthy Hosts!!! JitBit Application is down"
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    LoadBalancerName = local.jitbit["aws_lb_name"]
  }

  tags                = local.tags
}
