output "active_directory" {
  value = {
    id                = aws_directory_service_directory.active_directory.id
  }
}
