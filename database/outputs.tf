output "security_group_id" {
  value       = join("", aws_security_group.rds.*.id)
  description = "RDS Security Group ID"
}

output "security_group_name" {
  value       = join("", aws_security_group.rds.*.name)
  description = "RDS Security Group name"
}


output "database_info" {
  value = {
    endpoint              = module.db_instance.this_db_instance_endpoint
    instance_id           = module.db_instance.this_db_instance_id
    instance_arn          = module.db_instance.this_db_instance_arn
    address               = module.db_instance.this_db_instance_address
    security_group_id     = join("", aws_security_group.rds.*.id)
    database_ssm_user     = local.database_ssm_user
    database_ssm_password = local.database_ssm_password
  }
}
