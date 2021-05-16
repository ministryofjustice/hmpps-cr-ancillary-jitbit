module "active_directory" {
  source = "../modules/active_directory"

  common = local.common 
  ad     = local.ad
}
