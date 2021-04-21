locals {
  tags        = data.terraform_remote_state.common.outputs.tags
  kms_key_arn = data.terraform_remote_state.common.outputs.kms_arn
  common_name = data.terraform_remote_state.common.outputs.common_name
}
