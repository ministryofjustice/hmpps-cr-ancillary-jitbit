output "fsx" {
  value = {
    security_group_id             = aws_security_group.fsx.id
    integration_security_group_id = aws_security_group.fsx_integration.id
  }
}
