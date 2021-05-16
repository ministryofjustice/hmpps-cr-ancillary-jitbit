output "active_directory" {
  value = {
    access_url        = aws_directory_service_directory.active_directory.access_url
    dns_ip_addresses  = sort(aws_directory_service_directory.active_directory.dns_ip_addresses)
    domain_name       = var.ad.name
    domain_short_name = var.ad.short_name
    id                = aws_directory_service_directory.active_directory.id
    security_group_id = aws_directory_service_directory.active_directory.security_group_id
  }
}
