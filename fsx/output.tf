output "jitbit_ad" {
  value = {
    details = module.active_directory.active_directory
    integration_security_group_id = module.fsx.fsx
  }
}
