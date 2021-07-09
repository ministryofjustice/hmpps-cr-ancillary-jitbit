data "template_file" "userdata" {
  template = file("../user_data/jitbit_instance.tpl")

  vars = {
    ssm_adjoin_document_name = var.canary.ssm_adjoin_document_name
    filesystem_dns_name      = var.canary.filesystem_dns_name
    config_bucket            = var.canary.config_bucket
    cloudwatch_config        = var.canary.cloudwatch_config
    common_name              = var.common.common_name
    test                     = ""
  }
}

resource "aws_launch_configuration" "instance" {
  name_prefix                 = format("%s-inst-canary-%s", var.common.common_name, var.name)
  image_id                    = var.canary.image_id
  instance_type               = var.canary.instance_type
  iam_instance_profile        = var.canary.iam_instance_profile
  key_name                    = var.canary.key_name
  security_groups             = var.canary.security_groups
  associate_public_ip_address = false
  user_data                   = data.template_file.userdata.rendered
  enable_monitoring           = true
  ebs_optimized               = true

  root_block_device {
    volume_size = var.canary.volume_size
  }

  ebs_block_device {
    volume_size           = var.canary.disk_size
    iops                  = var.canary.iops
    device_name           = var.canary.device_name
    volume_type           = var.canary.volume_type
    encrypted             = true
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "null_data_source" "tags" {
  count = length(keys(var.common.tags))

  inputs = {
    key                 = element(keys(var.common.tags), count.index)
    value               = element(values(var.common.tags), count.index)
    propagate_at_launch = true
  }
}

resource "aws_placement_group" "instance" {
  name     = format("%s-inst-canary-%s", var.common.common_name, var.name)
  strategy = "spread"
}

resource "aws_autoscaling_group" "instance" {
  name                      = format("%s-inst-canary-%s", var.common.common_name, var.name)
  vpc_zone_identifier       = flatten(var.canary.subnet_ids)
  placement_group           = aws_placement_group.instance.id
  min_size                  = var.canary.min_size
  max_size                  = var.canary.max_size
  desired_capacity          = var.canary.desired_capacity
  target_group_arns         = aws_lb_target_group.instance.arn
  launch_configuration      = aws_launch_configuration.instance.name

  health_check_grace_period = var.canary.health_check_grace_period
  termination_policies      = ["OldestInstance", "OldestLaunchTemplate", "OldestLaunchConfiguration"]
  health_check_type         = "EC2"
  metrics_granularity       = var.canary.metrics_granularity
  enabled_metrics           = var.canary.enabled_metrics

  lifecycle {
    create_before_destroy = true
  }
  tags = concat(
    [
      {
        key                 = "Name"
        value               = format("%s-inst-canary-%s", var.common.common_name, var.name)
        propagate_at_launch = true
      },
    ],
    data.null_data_source.tags.*.outputs
  )
}

resource "aws_lb_target_group" "instance" {
  name                 = format("%s-tg-canary-%s", var.common.common_name, var.name)
  port                 = 443
  protocol             = "HTTPS"
  vpc_id               = var.canary.vpc_id
  deregistration_delay = 60
  target_type          = "instance"

  health_check {
    interval            = 30
    path                = "/User/Login?ReturnUrl=%2f"
    port                = 443
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = var.canary.cookie_duration
    enabled         = true
  }

  tags = merge(
    var.common.tags,
    {
      "Name" = format("%s-tg-canary-%s", var.common.common_name, var.name)
    },
  )
}
