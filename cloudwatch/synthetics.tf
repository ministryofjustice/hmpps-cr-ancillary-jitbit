module "synthetics" {
  source = "../modules/synthetics"

  common_name          = local.common_name
  health_check_url     = local.health_check_url
  artifact_s3_location = local.artifact_s3_location
}
