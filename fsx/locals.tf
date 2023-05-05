locals {
  ad = {
    admin_password = data.aws_ssm_parameter.ad_admin_password.value
    name           = "${var.environment_name}.local"     # cr-jitbit-dev.local
    short_name     = substr(var.environment_name, 0, 15) # 15 char limit in shortname for AD. ie. cr-jitbit-dev
  }
  common = {
    environment_name = var.environment_name
    subnet_ids       = tolist([local.private_subnet_ids[0], local.private_subnet_ids[1]])
    tags             = data.terraform_remote_state.common.outputs.tags
    vpc_id           = data.terraform_remote_state.common.outputs.vpc_id
    region           = var.region
  }
  fsx = {
    active_directory_id                = module.active_directory.active_directory["id"]
    automatic_backup_retention_days    = 7
    common_name                        = var.environment_name
    copy_tags_to_backups               = false
    daily_automatic_backup_start_time  = "03:00"
    deployment_type                    = "MULTI_AZ_1"
    filesystem_name                    = var.environment_name
    preferred_subnet_id                = local.private_subnet_ids[0]
    storage_capacity                   = var.storage_capacity
    throughput_capacity                = var.throughput_capacity
    active_directory_security_group_id = module.active_directory.active_directory["security_group_id"]
    sns_alarm_notification_arn         = data.terraform_remote_state.monitoring.outputs.aws_sns_topic_alarm_notification["arn"]
    migration_bucket_names = {
      cr-jitbit-dev = "delius-jitbit-development-20230124153927118900000002"
    }
  }
  private_subnet_ids = data.terraform_remote_state.common.outputs.private_subnet_ids
}
