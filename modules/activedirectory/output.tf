output "active_directory" {
  value = {
    id                    = aws_directory_service_directory.active_directory.id
    security_group_id     = aws_directory_service_directory.active_directory.security_group_id
    ssm_ad_auto_join_name = aws_ssm_document.awsconfig_domain_document.name
  }
}
