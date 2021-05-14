resource "aws_eip" "proxy" {
  vpc = true
  tags = merge(
    local.tags,
    {
      "Name" = format("%s-proxy", local.common_name)
    },
  )
}

resource "aws_launch_configuration" "proxy" {
  name_prefix          = format("%s-proxy", local.common_name)
  image_id             = local.ami_id
  instance_type        = local.jitbit_configs["instance_type"]
  iam_instance_profile = module.iam-instance-profile.iam_instance_name
  key_name             = local.ssh_deployer_key
  security_groups = [
    data.terraform_remote_state.common.outputs.sg_outbound_id,
    aws_security_group.proxy.id
  ]
  associate_public_ip_address = true
  # user_data                   = data.template_file.userdata.rendered
  enable_monitoring = true
  ebs_optimized     = true

  root_block_device {
    volume_size = local.jitbit_configs["volume_size"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_placement_group" "proxy" {
  name     = format("%s-proxy", local.common_name)
  strategy = "spread"
}

resource "aws_autoscaling_group" "proxy" {
  name                      = aws_launch_configuration.proxy.name
  vpc_zone_identifier       = flatten(local.public_subnet_ids)
  placement_group           = aws_placement_group.proxy.id
  min_size                  = local.jitbit_configs["asg_min_size"]
  max_size                  = local.jitbit_configs["asg_max_size"]
  desired_capacity          = local.jitbit_configs["asg_capacity"]
  launch_configuration      = aws_launch_configuration.proxy.name
  health_check_grace_period = local.jitbit_configs["health_check_grace_period"]
  termination_policies      = ["OldestInstance", "OldestLaunchTemplate", "OldestLaunchConfiguration"]
  health_check_type         = "EC2"
  metrics_granularity       = var.metrics_granularity
  enabled_metrics           = var.enabled_metrics

  lifecycle {
    create_before_destroy = true
  }
  tags = concat(
    [
      {
        key                 = "Name"
        value               = format("%s-proxy", local.common_name)
        propagate_at_launch = true
      },
    ],
    data.null_data_source.tags.*.outputs
  )
}
