output "jitbit" {
  value = {
    security_group_id              = aws_security_group.instance.id
    autoscaling_group_name         = module.blue.asg["autoscaling_group_name"]
    aws_lb_name                    = aws_lb.jitbit.name
    aws_lb_arn_suffix              = aws_lb.jitbit.arn_suffix
    aws_lb_target_group_name       = module.blue.asg["aws_lb_target_group_name"]
    aws_lb_target_group_arn_suffix = module.blue.asg["aws_lb_target_group_arn_suffix"]
    lb_security_group_id           = aws_security_group.lb.id
    aws_route53_record_name        = aws_route53_record.jitbit.name
    canary_sns_notification        = module.mgmt.aws_sns_topic_mgmt_notification["arn"]
  }
}
