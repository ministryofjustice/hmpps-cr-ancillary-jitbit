output "arn" {
  value       = join("", aws_efs_file_system.default.*.arn)
  description = "EFS ARN"
}

output "id" {
  value       = join("", aws_efs_file_system.default.*.id)
  description = "EFS ID"
}

output "dns_name" {
  value       = local.dns_name
  description = "EFS DNS name"
}

output "mount_target_dns_names" {
  value       = coalescelist(aws_efs_mount_target.default.*.mount_target_dns_name, [""])
  description = "List of EFS mount target DNS names"
}

output "mount_target_ids" {
  value       = coalescelist(aws_efs_mount_target.default.*.id, [""])
  description = "List of EFS mount target IDs (one per Availability Zone)"
}

output "mount_target_ips" {
  value       = coalescelist(aws_efs_mount_target.default.*.ip_address, [""])
  description = "List of EFS mount target IPs (one per Availability Zone)"
}

output "security_group_id" {
  value       = join("", aws_security_group.efs.*.id)
  description = "EFS Security Group ID"
}

output "security_group_name" {
  value       = join("", aws_security_group.efs.*.name)
  description = "EFS Security Group name"
}
