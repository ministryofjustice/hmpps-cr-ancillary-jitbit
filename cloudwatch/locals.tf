locals {
  common_name = data.terraform_remote_state.common.outputs.common_name
  common      = {
    environment_name = local.common_name
    tags             = data.terraform_remote_state.common.outputs.tags
  } 
  synthetics  = {
    health_check_url           = data.terraform_remote_state.jitbit.outputs.jitbit["aws_route53_record_name"]
    artifact_s3_location       = "s3://${local.common_name}/synthetics/"
    subnet_ids                 = data.terraform_remote_state.common.outputs.private_subnet_ids
    inbound_security_group_id  = data.terraform_remote_state.jitbit.outputs.jitbit["lb_security_group_id"]
    outbound_security_group_id = data.terraform_remote_state.common.outputs.sg_outbound_id     
  }
}
