locals {
  cr_jitbit_rds_options = merge(var.cr_jitbit_rds_config, var.cr_jitbit_rds_overrides)
  tags = merge(
    data.terraform_remote_state.common.outputs.tags,
    {
      "autostop" = var.rds_stop_resources_tag_phase1
    },
  )
  kms_key_arn  = data.terraform_remote_state.common.outputs.kms_arn
  common_name  = data.terraform_remote_state.common.outputs.common_name
  subnet_ids   = data.terraform_remote_state.common.outputs.db_subnet_ids
  vpc_id       = data.terraform_remote_state.common.outputs.vpc_id
  db_name      = "jitbit"
  db_user_name = data.aws_ssm_parameter.db_user.value
  db_password  = data.aws_ssm_parameter.db_password.value
}
