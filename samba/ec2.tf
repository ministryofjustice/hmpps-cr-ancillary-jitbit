data "template_file" "userdata" {
  template = file("../user_data/storage_instance.sh")

  vars = {}
}
resource "aws_launch_configuration" "instance" {
  name_prefix          = "${local.common_name}-storage-inst-"
  image_id             = local.ami_id
  instance_type        = local.jitbit_samba_configs["instance_type"]
  iam_instance_profile = module.iam-instance-profile.iam_instance_name
  key_name             = local.ssh_deployer_key
  security_groups = [
    data.terraform_remote_state.common.outputs.sg_outbound_id,
    aws_security_group.gateway.id,
    aws_security_group.storage_endpoint.id
  ]
  associate_public_ip_address = true
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

resource "aws_placement_group" "instance" {
  name     = "${local.common_name}-storage-inst"
  strategy = "spread"
}

resource "aws_autoscaling_group" "instance" {
  name                = aws_launch_configuration.instance.name
  vpc_zone_identifier = flatten(local.public_subnet_ids)
  placement_group     = aws_placement_group.instance.id
  min_size            = local.jitbit_samba_configs["asg_min_size"]
  max_size            = local.jitbit_samba_configs["asg_max_size"]
  desired_capacity    = local.jitbit_samba_configs["asg_capacity"]
  # target_group_arns         = [aws_lb_target_group.storage.arn]
  launch_configuration      = aws_launch_configuration.instance.name
  health_check_grace_period = 180
  termination_policies      = ["OldestInstance", "OldestLaunchTemplate", "OldestLaunchConfiguration"]
  health_check_type         = "EC2" #local.jitbit_samba_configs["health_check_type"]
  metrics_granularity       = var.metrics_granularity
  enabled_metrics           = var.enabled_metrics
  # min_elb_capacity          = local.jitbit_samba_configs["min_elb_capacity"]
  # wait_for_capacity_timeout = local.jitbit_samba_configs["wait_for_capacity_timeout"]

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
