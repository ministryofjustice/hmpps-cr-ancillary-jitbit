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
