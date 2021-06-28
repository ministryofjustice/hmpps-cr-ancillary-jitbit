locals {
  common_name          = data.terraform_remote_state.common.outputs.common_name
  health_check_url     = data.terraform_remote_state.jitbit.outputs.jitbit["aws_route53_record_name"]
  artifact_s3_location = "s3://${local.common_name}/synthetics/"
}
 