module "fsx" {
  source = "../modules/fsx"

  common = local.common  
  fxs     = local.fsx
}
