module "synthetics" {
  source = "../modules/synthetics"

  common_name      = local.common_name
  health_check_url = local.health_check_url
}
