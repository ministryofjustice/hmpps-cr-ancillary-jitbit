data "template_file" "userdata" {
  template = file("../user_data/storage_instance.sh")

  vars = {
    account_id        = local.account_id
    bastion_inventory = var.bastion_inventory
    common_name       = local.common_name
  }
}

resource "aws_launch_configuration" "samba" {
  name_prefix                 = "${local.common_name}-samba-"
  image_id                    = local.ami_id
  instance_type               = local.jitbit_samba_configs["instance_type"]
  iam_instance_profile        = module.iam-instance-profile.iam_instance_name
  key_name                    = local.ssh_deployer_key
  security_groups             = flatten(local.common_sgs)
  associate_public_ip_address = false
  user_data                   = data.template_file.userdata.rendered
  enable_monitoring           = true
  ebs_optimized               = true

  root_block_device {
    volume_size = local.jitbit_samba_configs["volume_size"]
  }

  ebs_block_device {
    volume_size           = local.jitbit_samba_configs["cache_disk_size"]
    iops                  = local.jitbit_samba_configs["cache_iops"]
    device_name           = local.jitbit_samba_configs["cache_device_name"]
    volume_type           = local.jitbit_samba_configs["cache_volume_type"]
    encrypted             = true
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "null_data_source" "tags" {
  count = length(keys(local.tags))

  inputs = {
    key                 = element(keys(local.tags), count.index)
    value               = element(values(local.tags), count.index)
    propagate_at_launch = true
  }
}

resource "aws_placement_group" "samba" {
  name     = "${local.common_name}-samba"
  strategy = "spread"
}

resource "aws_autoscaling_group" "samba" {
  name                      = aws_launch_configuration.samba.name
  vpc_zone_identifier       = flatten(local.subnet_ids)
  placement_group           = aws_placement_group.samba.id
  min_size                  = local.jitbit_samba_configs["asg_min_size"]
  max_size                  = local.jitbit_samba_configs["asg_max_size"]
  desired_capacity          = local.jitbit_samba_configs["asg_capacity"]
  target_group_arns         = [aws_lb_target_group.samba.arn]
  launch_configuration      = aws_launch_configuration.samba.name
  health_check_grace_period = 500
  termination_policies      = ["OldestInstance", "OldestLaunchTemplate", "OldestLaunchConfiguration"]
  health_check_type         = local.jitbit_samba_configs["health_check_type"]
  metrics_granularity       = var.metrics_granularity
  enabled_metrics           = var.enabled_metrics
  min_elb_capacity          = local.jitbit_samba_configs["min_elb_capacity"]
  wait_for_capacity_timeout = local.jitbit_samba_configs["wait_for_capacity_timeout"]

  lifecycle {
    create_before_destroy = true
  }
  tags = concat(
    [
      {
        key                 = "Name"
        value               = "${local.common_name}-samba"
        propagate_at_launch = true
      },
    ],
    data.null_data_source.tags.*.outputs
  )
}
