#  CloudWatch Dasboards
data "template_file" "dashboard" {
  template = file("./files/dashboard.json")
  vars = {
    region                  = var.region
# TO be fixed
    asg_autoscale_name      = "cr-jitbit-dev-inst20210601135148702100000001"  
# TO be fixed
    common_prefix           = local.common_name
    lb_arn_suffix           = data.aws_lb.alb.arn_suffix
    target_group_arn_suffix = data.aws_lb_target_group.target_group.arn_suffix
  }
}


resource "aws_cloudwatch_dashboard" "jitbit" {
  dashboard_name = local.common_name
  dashboard_body = data.template_file.dashboard.rendered
}


data "aws_lb_target_group" "target_group" {
  name = "${local.common_name}-tg"
}

data "aws_lb" "alb" {
  name = "${local.common_name}-lb"
}
