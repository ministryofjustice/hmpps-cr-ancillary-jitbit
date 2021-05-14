output "region" {
  value = local.region
}

output "account_id" {
  value = local.account_id
}

output "vpc_id" {
  value = local.vpc_id
}

output "vpc_cidr_block" {
  value = local.cidr_block
}

output "common_name" {
  value = local.common_name
}

output "lb_account_id" {
  value = var.lb_account_id
}

output "role_arn" {
  value = var.role_arn
}

output "sg_outbound_id" {
  value = aws_security_group.outbound.id
}

output "lb_logs_bucket" {
  value = module.s3_lb_logs_bucket.s3_bucket_name
}

output "s3bucket-logs" {
  value = module.s3bucket-logs.s3_bucket_name
}

output "config_bucket" {
  value = {
    name = module.s3config_bucket.s3_bucket_name
    arn  = module.s3config_bucket.s3_bucket_arn
  }
}

# KMS Key
output "kms_arn" {
  value = aws_kms_key.kms.arn
}

output "kms_id" {
  value = aws_kms_key.kms.id
}

output "log_group" {
  value = {
    log_group_arn  = aws_cloudwatch_log_group.logs.arn
    log_group_name = aws_cloudwatch_log_group.logs.name
    kms_id         = aws_cloudwatch_log_group.logs.kms_key_id
  }
}

output "tags" {
  value = local.tags
}

output "bastion_cidr_ranges" {
  value = [
    local.bastion_cidr_ranges["az1"],
    local.bastion_cidr_ranges["az2"],
    local.bastion_cidr_ranges["az3"]
  ]
}

output "domain_info" {
  value = {
    external_domain    = local.external_domain
    external_domain_id = local.external_domain_id
    public_acm_arn     = local.public_acm_arn
    private_domain     = local.private_domain
  }
}
