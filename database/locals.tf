locals {
  cr_jitbit_rds_options = merge(var.cr_jitbit_rds_config, var.cr_jitbit_rds_overrides)
  tags                  = data.terraform_remote_state.common.outputs.tags
  kms_key_arn           = data.terraform_remote_state.common.outputs.kms_arn
  common_name           = data.terraform_remote_state.common.outputs.common_name
  subnet_ids            = data.terraform_remote_state.common.outputs.db_subnet_ids
  vpc_id                = data.terraform_remote_state.common.outputs.vpc_id
  db_name               = "jitbit"
  database_ssm_user     = "${local.cr_jitbit_rds_options["credentials_ssm_path"]}/user"
  database_ssm_password = "${local.cr_jitbit_rds_options["credentials_ssm_path"]}/password"
  db_user_name          = data.aws_ssm_parameter.db_user.value
  db_password           = data.aws_ssm_parameter.db_password.value
}
