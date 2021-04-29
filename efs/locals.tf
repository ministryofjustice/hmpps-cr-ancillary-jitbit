locals {
  jitbit_efs_configs = merge(var.jitbit_efs_configs, var.jitbit_efs_overrides)
  tags               = data.terraform_remote_state.common.outputs.tags
  kms_key_arn        = data.terraform_remote_state.common.outputs.kms_arn
  common_name        = data.terraform_remote_state.common.outputs.common_name
  subnet_ids         = data.terraform_remote_state.common.outputs.db_subnet_ids
  vpc_id             = data.terraform_remote_state.common.outputs.vpc_id
}
