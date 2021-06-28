module "synthetics" {
  source = "../modules/synthetics"

  common_name     = local.common_name
  healthchech_url = local.jitbit["aws_route53_record_name"]
}
