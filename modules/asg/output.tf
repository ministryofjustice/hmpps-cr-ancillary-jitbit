output "asg" {
  value = {
    aws_lb_target_group_arn  = aws_lb_target_group.instance.arn
    aws_lb_target_group_arn_suffix = aws_lb_target_group.instance.arn_suffix
    aws_lb_target_group_name = aws_lb_target_group.instance.name
    autoscaling_group_name = aws_autoscaling_group.instance.name
  }
}
