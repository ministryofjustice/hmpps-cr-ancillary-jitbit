module "active_directory" {
  source = "../modules/activedirectory"

  ad     = local.ad
  common = local.common 
}
