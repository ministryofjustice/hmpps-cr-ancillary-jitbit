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

# KMS Key
output "kms_arn" {
  value = aws_kms_key.kms.arn
}

output "kms_id" {
  value = aws_kms_key.kms.id
}
