data "template_file" "userdata" {
  template = file("../user_data/samba_instance.sh")

  vars = {
    environment_name        = local.common_name
    app_name                = local.app_name
    external_domain         = local.external_domain
    account_id              = local.account_id
    private_domain          = local.private_domain
    bastion_inventory       = var.bastion_inventory
    log_group               = local.log_group_name
    samba_version           = var.source_code_versions["samba"]
    bootstrap_version       = var.source_code_versions["bootstrap"]
    samba_bootstrap_version = var.source_code_versions["samba_bootstrap"]
    samba_share             = local.samba_share
    samba_ssm_user          = local.samba_ssm_user
    samba_ssm_password      = local.samba_ssm_password
    samba_gid               = local.jitbit_efs_configs["group_gid"]
    samba_uid               = local.jitbit_efs_configs["user_uid"]
    data_dir                = local.jitbit_efs_configs["data_dir"]
    efs_dns_name            = local.efs_dns_name
  }
}
resource "aws_launch_configuration" "instance" {
  name_prefix          = "${local.common_name}-samba-inst-"
  image_id             = local.ami_id
  instance_type        = local.jitbit_samba_configs["instance_type"]
  iam_instance_profile = module.iam-instance-profile.iam_instance_name
  key_name             = local.ssh_deployer_key
  security_groups = [
    data.terraform_remote_state.common.outputs.sg_outbound_id,
    aws_security_group.gateway.id,
    aws_security_group.storage_endpoint.id
  ]
  associate_public_ip_address = false
  user_data                   = data.template_file.userdata.rendered
  enable_monitoring           = true
  ebs_optimized               = true

  root_block_device {
    volume_size = local.jitbit_samba_configs["volume_size"]
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
  name     = "${local.common_name}-samba-inst"
  strategy = "spread"
}

resource "aws_autoscaling_group" "instance" {
  name                      = aws_launch_configuration.instance.name
  vpc_zone_identifier       = flatten(local.subnet_ids)
  placement_group           = aws_placement_group.instance.id
  min_size                  = local.jitbit_samba_configs["asg_min_size"]
  max_size                  = local.jitbit_samba_configs["asg_max_size"]
  desired_capacity          = local.jitbit_samba_configs["asg_capacity"]
  load_balancers            = [aws_elb.samba_lb.id]
  launch_configuration      = aws_launch_configuration.instance.name
  health_check_grace_period = local.jitbit_samba_configs["health_check_grace_period"]
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
