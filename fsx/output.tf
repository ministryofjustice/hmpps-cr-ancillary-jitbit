output "fsx" {
  value = {
    ad_details  = module.active_directory.active_directory
    fsx_details = module.fsx.fsx
  }
}
