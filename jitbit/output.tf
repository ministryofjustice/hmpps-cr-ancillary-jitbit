output "jitbit" {
  value = {
    security_group_id = aws_security_group.instance.id
  }
}
