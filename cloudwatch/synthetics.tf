module "synthetics" {
  source = "../modules/synthetics"

  common_name                   = local.common_name
  health_check_url              = local.health_check_url
  artifact_s3_location          = local.artifact_s3_location
  subnet_ids                    = data.terraform_remote_state.common.outputs.private_subnet_ids
  lb_inbound_security_group_id  = data.terraform_remote_state.jitbit.outputs.jitbit["lb_security_group_id"]
  lb_outbound_security_group_id = data.terraform_remote_state.common.outputs.sg_outbound_id     
  tags                          = data.terraform_remote_state.common.outputs.tags
}
