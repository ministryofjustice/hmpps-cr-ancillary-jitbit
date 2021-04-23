output "security_group_id" {
  value       = join("", aws_security_group.rds.*.id)
  description = "RDS Security Group ID"
}

output "security_group_name" {
  value       = join("", aws_security_group.rds.*.name)
  description = "RDS Security Group name"
}
