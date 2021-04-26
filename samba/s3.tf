# #-------------------------------------------
# ### S3 bucket for storage
# #--------------------------------------------
module "s3bucket" {
  source              = "../modules/s3/s3bucket_logging_encryption"
  s3_bucket_name      = "${local.common_name}-storage"
  kms_master_key_id   = local.kms_key_arn
  target_bucket       = local.s3bucket-logs
  versioning          = true
  tags                = local.tags
  s3_lifecycle_config = var.s3_lifecycle_config
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = local.vpc_id
  service_name = data.aws_vpc_endpoint_service.s3.service_name
  tags = merge(
    local.tags,
    { "Name" : "${local.common_name}-s3" }
  )
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  for_each        = toset(data.aws_route_tables.routes.ids)
  route_table_id  = each.value
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
