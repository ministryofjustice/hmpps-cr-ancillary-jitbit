locals {
  account_id          = data.aws_caller_identity.current.account_id
  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  cidr_block          = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  application         = "jitbit"
  common_name         = "${var.short_environment_name}"
  lb_account_id       = var.lb_account_id
  region              = var.region
  role_arn            = var.role_arn
  bastion_cidr_ranges = data.terraform_remote_state.bastion_remote_vpc.outputs.bastion_public_cidr
  tags = merge(
    var.tags,
    {
      "sub-project" = local.application
    },
    {
      "source-hash" = "ignored"
    },
    {
      "source-code" = "https://github.com/ministryofjustice/hmpps-cr-ancillary-jitbit"
    }
  )
}
