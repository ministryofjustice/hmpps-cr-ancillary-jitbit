resource "aws_elb" "samba_lb" {
  name     = "${local.common_name}-samba-lb"
  internal = true
  subnets  = flatten(local.subnet_ids)
  tags     = local.tags
  security_groups = [
    aws_security_group.lb.id,
    data.terraform_remote_state.common.outputs.sg_outbound_id
  ]

  access_logs {
    bucket        = local.lb_logs_bucket
    bucket_prefix = "${local.common_name}-samba-lb"
    interval      = 60
    enabled       = true
  }
  listener {
    instance_port     = "445"
    instance_protocol = "tcp"
    lb_port           = "445"
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:445"
    interval            = 30
  }
}
