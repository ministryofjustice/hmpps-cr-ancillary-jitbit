locals {
  jitbit_configs                    = merge(var.cr_jitbit_configs, var.cr_jitbit_overrides)
  ami_id                            = data.aws_ami.ami.id
  tags                              = data.terraform_remote_state.common.outputs.tags
  kms_key_arn                       = data.terraform_remote_state.common.outputs.kms_arn
  common_name                       = data.terraform_remote_state.common.outputs.common_name
  public_subnet_ids                 = data.terraform_remote_state.common.outputs.public_subnet_ids
  subnet_ids                        = data.terraform_remote_state.common.outputs.private_subnet_ids
  vpc_id                            = data.terraform_remote_state.common.outputs.vpc_id
  s3bucket-logs                     = data.terraform_remote_state.common.outputs.s3bucket-logs
  lb_logs_bucket                    = data.terraform_remote_state.common.outputs.lb_logs_bucket
  account_id                        = data.terraform_remote_state.common.outputs.account_id
  ssh_deployer_key                  = data.terraform_remote_state.vpc.outputs.ssh_deployer_key
  cidr_block                        = data.terraform_remote_state.common.outputs.private_cidr_block
  vpc_cidr_block                    = data.terraform_remote_state.common.outputs.vpc_cidr_block
  bastion_cidr_ranges               = data.terraform_remote_state.common.outputs.bastion_cidr_ranges
  log_group_arn                     = data.terraform_remote_state.common.outputs.log_group["log_group_arn"]
  log_group_name                    = data.terraform_remote_state.common.outputs.log_group["log_group_name"]
  external_domain                   = data.terraform_remote_state.common.outputs.domain_info["external_domain"]
  internal_domain                   = data.terraform_remote_state.common.outputs.domain_info["private_domain"]
  public_acm_arn                    = data.terraform_remote_state.common.outputs.domain_info["public_acm_arn"]
  private_domain                    = data.terraform_remote_state.common.outputs.domain_info["private_domain"]
  app_name                          = "jitbit"
  bucket_arn                        = data.terraform_remote_state.common.outputs.config_bucket["arn"]
  database_address                  = data.terraform_remote_state.database.outputs.database_info["address"]
  database_endpoint                 = data.terraform_remote_state.database.outputs.database_info["endpoint"]
  database_ssm_user                 = data.terraform_remote_state.database.outputs.database_info["database_ssm_user"]
  database_ssm_password             = data.terraform_remote_state.database.outputs.database_info["database_ssm_password"]
  database_security_group_id        = data.terraform_remote_state.database.outputs.database_info["security_group_id"]
  installer_files_s3_prefix         = "installers/HelpDesk_10.14"
  public_zone_id                    = data.terraform_remote_state.common.outputs.domain_info["external_domain_id"]
  private_zone_id                   = data.terraform_remote_state.vpc.outputs.private_zone_id
  bastion_public_ip                 = ["${data.terraform_remote_state.bastion.outputs.bastion_ip}/32"]
  fsx_integration_security_group_id = data.terraform_remote_state.fsx.outputs.fsx.fsx_details["integration_security_group_id"]
  config_bucket                     = data.terraform_remote_state.common.outputs.config_bucket["name"]
  natgateway_public_ip = [
    "${data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-public-ip-az1}/32",
    "${data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-public-ip-az2}/32",
    "${data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-public-ip-az3}/32"
  ]

  migrated_environments  = ["cr-jitbit-dev", "cr-jitbit-training", "cr-jitbit-preprod"]
  modPlatformUrlTemplate = "https://delius-jitbit.%s.modernisation-platform.service.justice.gov.uk/"
  modplatformUrls = {
    "cr-jitbit-dev" : format(local.modPlatformUrlTemplate, "hmpps-development"),
    "cr-jitbit-training" : format(local.modPlatformUrlTemplate, "hmpps-test"),
    "cr-jitbit-preprod" : format(local.modPlatformUrlTemplate, "hmpps-preproduction"),
    "cr-jitbit-prod" : "https://helpdesk.jitbit.cr.probation.service.justice.gov.uk/"
  }
}
