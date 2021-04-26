locals {
  jitbit_samba_configs = merge(var.jitbit_samba_configs, var.jitbit_samba_overrides)
  ami_id               = data.aws_ssm_parameter.storage_ami.value #data.aws_ami.ami.id
  tags                 = data.terraform_remote_state.common.outputs.tags
  kms_key_arn          = data.terraform_remote_state.common.outputs.kms_arn
  common_name          = data.terraform_remote_state.common.outputs.common_name
  subnet_ids           = data.terraform_remote_state.common.outputs.private_subnet_ids
  vpc_id               = data.terraform_remote_state.common.outputs.vpc_id
  s3bucket-logs        = data.terraform_remote_state.common.outputs.s3bucket-logs
  lb_logs_bucket       = data.terraform_remote_state.common.outputs.lb_logs_bucket
  account_id           = data.terraform_remote_state.common.outputs.account_id
  ssh_deployer_key     = data.terraform_remote_state.vpc.outputs.ssh_deployer_key
  cidr_block           = data.terraform_remote_state.common.outputs.private_cidr_block
  vpc_cidr_block       = data.terraform_remote_state.common.outputs.vpc_cidr_block
  common_sgs = [
    data.terraform_remote_state.common.outputs.sg_outbound_id,
    aws_security_group.samba.id
  ]
}
