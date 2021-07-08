locals {
  security_group = [
    aws_security_group.instance.id,
    data.terraform_remote_state.common.outputs.sg_outbound_id,
    local.fsx_integration_security_group_id
  ]
}

module "active" {
  source = "../modules/asg"

  common = {
    common_name              = local.common_name
    tags                     = local.tags
  }
  canary = {
    ssm_adjoin_document_name = data.terraform_remote_state.fsx.outputs.fsx.ad_details["ssm_ad_auto_join_name"]
    filesystem_dns_name      = data.terraform_remote_state.fsx.outputs.fsx.fsx_details["dns_name"]
    config_bucket            = local.config_bucket
    cloudwatch_config        = "cloudwatch/config.json"
    image_id                 = local.ami_id
    instance_type            = local.jitbit_configs["instance_type"]
    iam_instance_profile     = module.iam-instance-profile.iam_instance_name
    key_name                 = local.ssh_deployer_key
    security_groups          = local.security_group
    volume_size              = local.jitbit_configs["volume_size"]
    disk_size                = local.jitbit_configs["cache_disk_size"]
    iops                     = local.jitbit_configs["cache_iops"]
    device_name              = local.jitbit_configs["cache_device_name"]
    volume_type              = local.jitbit_configs["cache_volume_type"]
    subnet_ids               = local.subnet_ids
    min_size                 = local.jitbit_configs["asg_min_size"]
    max_size                 = local.jitbit_configs["asg_max_size"]
    desired_capacity         = local.jitbit_configs["asg_capacity"]
  }

}