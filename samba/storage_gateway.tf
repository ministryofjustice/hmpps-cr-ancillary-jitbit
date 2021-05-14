resource "aws_launch_configuration" "gateway" {
  name_prefix          = "${local.common_name}-gateway-"
  image_id             = data.aws_ssm_parameter.storage_ami.value
  instance_type        = local.jitbit_samba_configs["instance_type"]
  iam_instance_profile = module.iam-instance-profile.iam_instance_name
  key_name             = local.ssh_deployer_key
  security_groups = [
    data.terraform_remote_state.common.outputs.sg_outbound_id,
    aws_security_group.storage_gateway.id
  ]
  associate_public_ip_address = true
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

resource "aws_placement_group" "gateway" {
  name     = "${local.common_name}-gateway"
  strategy = "spread"
}

resource "aws_autoscaling_group" "gateway" {
  name                      = aws_launch_configuration.gateway.name
  vpc_zone_identifier       = flatten(local.public_subnet_ids)
  placement_group           = aws_placement_group.gateway.id
  min_size                  = local.jitbit_samba_configs["asg_min_size"]
  max_size                  = local.jitbit_samba_configs["asg_max_size"]
  desired_capacity          = local.jitbit_samba_configs["asg_capacity"]
  launch_configuration      = aws_launch_configuration.gateway.name
  health_check_grace_period = 500
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
        value               = "${local.common_name}-gateway"
        propagate_at_launch = true
      },
    ],
    data.null_data_source.tags.*.outputs
  )
}


resource "aws_vpc_endpoint" "storage" {
  vpc_id              = local.vpc_id
  subnet_ids          = local.subnet_ids
  service_name        = "com.amazonaws.${var.region}.storagegateway"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = false
  security_group_ids = [
    aws_security_group.storage_gateway.id
  ]
  tags = merge(
    local.tags,
    { "Name" : "${local.common_name}-storage-gateway" }
  )
}


resource "aws_storagegateway_gateway" "storage" {
  gateway_ip_address       = "18.134.11.142" #hard code for now
  gateway_name             = format("%s-storage-gw", local.common_name)
  gateway_timezone         = "GMT"
  gateway_type             = "FILE_S3"
  tags                     = local.tags
  smb_guest_password       = local.smb_guest_password
  cloudwatch_log_group_arn = local.log_group_arn
}

data "aws_storagegateway_local_disk" "storage" {
  disk_path   = local.jitbit_samba_configs["cache_device_name"]
  gateway_arn = aws_storagegateway_gateway.storage.arn
}

resource "aws_storagegateway_cache" "storage" {
  disk_id     = data.aws_storagegateway_local_disk.storage.disk_id
  gateway_arn = aws_storagegateway_gateway.storage.arn
}

resource "aws_storagegateway_smb_file_share" "storage" {
  authentication = "GuestAccess"
  gateway_arn    = aws_storagegateway_gateway.storage.arn
  location_arn   = module.s3bucket.s3_bucket_arn
  role_arn       = module.iam-app-role.iamrole_arn
  tags           = local.tags
  kms_encrypted  = true
  kms_key_arn    = local.kms_key_arn
}
