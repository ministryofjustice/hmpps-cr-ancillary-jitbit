data "aws_lb_target_group" "target_group" {
  name = local.jitbit["aws_lb_target_group_name"]
}

data "aws_lb_target_group" "passive_target_group" {
  name = local.jitbit["passive_aws_lb_target_group_name"]
}

data "aws_lb" "alb" {
  name = local.jitbit["aws_lb_name"]
}

data "template_file" "dashboard" {
  template = file("./files/dashboard.json")
  vars = {
    region                          = var.region
    common_prefix                   = local.common_name
    lb_arn_suffix                   = data.aws_lb.alb.arn_suffix
    asg_autoscale_name              = local.jitbit["autoscaling_group_name"]
    target_group_arn_suffix         = data.aws_lb_target_group.target_group.arn_suffix
    passive_autoscaling_group_name  = local.jitbit["passive_autoscaling_group_name"]
    passive_target_group_arn_suffix = data.aws_lb_target_group.passive_target_group.arn_suffix
    app_pool_httperr_offline        = aws_cloudwatch_metric_alarm.iis_httperr.arn
  }
}

resource "aws_cloudwatch_dashboard" "jitbit" {
  dashboard_name = local.common_name
  dashboard_body = data.template_file.dashboard.rendered
}
