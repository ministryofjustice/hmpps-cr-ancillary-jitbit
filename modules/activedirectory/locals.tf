locals {
  directory_id         = aws_directory_service_directory.active_directory.id
  directory_name       = aws_directory_service_directory.active_directory.name
  directory_short_name = aws_directory_service_directory.active_directory.short_name
  directory_dns_ips    = sort(aws_directory_service_directory.active_directory.dns_ip_addresses)
}
