locals {
  common_name = data.terraform_remote_state.common.outputs.common_name
  jitbit = data.terraform_remote_state.jitbit.outputs.jitbit
}
