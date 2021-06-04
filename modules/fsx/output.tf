output "fsx" {
  value = {
    security_group_id             = aws_security_group.fsx.id
    integration_security_group_id = aws_security_group.fsx_integration.id
    dns_name                      = aws_fsx_windows_file_system.fsx.dns_name
  }
}
