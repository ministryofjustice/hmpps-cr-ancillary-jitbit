#  CloudWatch Dasboards
data "template_file" "dashboard" {
  template = file("./files/dashboard.json")
  vars = {
    region                   = var.region
# TO be fixed
    asg_autoscale_name       = "cr-jitbit-dev-inst20210601135148702100000001"  
# TO be fixed
    common_prefix            = local.common_name
    lb_arn_suffix            = data.aws_lb.alb.arn_suffix
    target_group_arn_suffix  = data.aws_lb_target_group.target_group.arn_suffix
    app_pool_httperr_offline = aws_cloudwatch_metric_alarm.iis_httperr.name
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



# FSX 
data "template_file" "fsx_dashboard" {
  template = file("./files/fsx_dashboard.json")
  vars = {
    region           = var.region
# TO be fixed
    filesystemid     = "fs-01eb9318811b3b6e4"
# TO be fixed
  }
}

resource "aws_cloudwatch_dashboard" "fsx" {
  dashboard_name = "${local.common_name}-monitoring-fsx-filesystem"
  dashboard_body = data.template_file.fsx_dashboard.rendered
}
