locals {
  environment        = replace("${var.environment_type}", "jitbit-", "")
  subdomain          = "${local.environment == "dev" ? "mail.${local.environment}" : "mail" }"
  mail_public_domain = "${local.subdomain}.${var.project_name}.probation.${var.public_dns_parent_zone}"
  tags               = data.terraform_remote_state.common.outputs.tags
}
