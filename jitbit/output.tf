output "jitbit" {
  value = {
    security_group_id        = aws_security_group.instance.id
    autoscaling_group_name   = aws_autoscaling_group.instance.name
    aws_lb_name              = aws_lb.instance.name
    aws_lb_target_group_name = aws_lb_target_group.instance.name
    aws_route53_record_name  = aws_route53_record.dns_entry.name
  }
}
