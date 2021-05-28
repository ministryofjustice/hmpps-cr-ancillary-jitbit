module "fsx" {
  source = "../modules/fsx"

  common = local.common
  fsx    = local.fsx
}
