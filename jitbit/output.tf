output "jitbit" {
  value = {
    security_group_id              = aws_security_group.instance.id
    autoscaling_group_name         = aws_autoscaling_group.instance.name
    aws_lb_name                    = aws_lb.instance.name
    aws_lb_arn_suffix              = aws_lb.instance.arn_suffix
    aws_lb_target_group_name       = aws_lb_target_group.instance.name
    aws_lb_target_group_arn_suffix = aws_lb_target_group.instance.arn_suffix
    lb_security_group_id           = aws_security_group.lb.id
    aws_route53_record_name        = aws_route53_record.dns_entry.name
    canary_sns_notification        = module.mgmt.aws_sns_topic_mgmt_notification["arn"]
  }
}
