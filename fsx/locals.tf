locals {
  common = {
    environment_name  = var.environment_name
    subnet_ids        = data.terraform_remote_state.common.outputs.private_subnet_ids
    tags              = data.terraform_remote_state.common.outputs.tags
    vpc_id            = data.terraform_remote_state.common.outputs.vpc_id
  }
  ad = {
    admin_password = data.aws_ssm_parameter.ad_admin_password.value
    name           = "${var.environment_name}.local" # cr-jitbit-dev.local
    short_name     = substr(var.environment_name,0,15) # 15 char limit in shortname for AD. ie. cr-jitbit-dev
  }
}
