locals {
  ad = {
    admin_password = data.aws_ssm_parameter.ad_admin_password.value
    name           = "${var.environment_name}.local" # cr-jitbit-dev.local
    short_name     = substr(var.environment_name,0,15) # 15 char limit in shortname for AD. ie. cr-jitbit-dev
  }
  common = {
    environment_name  = var.environment_name
    subnet_ids        = tolist([local.private_subnet_ids[0], local.private_subnet_ids[1]])
    tags              = data.terraform_remote_state.common.outputs.tags
    vpc_id            = data.terraform_remote_state.common.outputs.vpc_id
  }
  fsx = {
    active_directory_id               = module.active_directory.active_directory["id"]
    automatic_backup_retention_days   = 7
    bfs_fileshare_size                = ""
    bfs_fileshare_throughput          = "" 
    bfs_filesystem_name               = "jitbit-bfs"
    copy_tags_to_backups              = false
    daily_automatic_backup_start_time = "03:00"
    deployment_type                   = "MULTI_AZ_1"
    preferred_subnet_id               = local.private_subnet_ids[0]
    storage_capacity                  = 10 # GiB
    throughput_capacity               = 64 # MB/s
  }
  private_subnet_ids = data.terraform_remote_state.common.outputs.private_subnet_ids
}
