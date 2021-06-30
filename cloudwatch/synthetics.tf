module "synthetics" {
  source = "../modules/synthetics"

  common     = local.common
  synthetics = local.synthetics
}
