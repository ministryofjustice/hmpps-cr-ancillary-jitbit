# resource "aws_vpc_endpoint" "storage" {
#   vpc_id              = local.vpc_id
#   subnet_ids          = local.subnet_ids
#   service_name        = "com.amazonaws.${var.region}.storagegateway"
#   vpc_endpoint_type   = "Interface"
#   private_dns_enabled = false
#   security_group_ids = [
#     aws_security_group.storage_endpoint.id
#   ]
#   tags = merge(
#     local.tags,
#     { "Name" : "${local.common_name}-storage-gateway" }
#   )
# }


resource "aws_storagegateway_gateway" "storage" {
  gateway_ip_address       = "3.9.115.211"
  gateway_name             = format("%s-storage-gw", local.common_name)
  gateway_timezone         = "GMT"
  gateway_type             = "FILE_S3"
  tags                     = local.tags
  smb_guest_password       = local.storage_password
  cloudwatch_log_group_arn = local.log_group_arn
}

data "aws_storagegateway_local_disk" "storage" {
  disk_path   = local.jitbit_samba_configs["cache_device_name"]
  gateway_arn = aws_storagegateway_gateway.storage.arn
}

resource "aws_storagegateway_cache" "storage" {
  disk_id     = data.aws_storagegateway_local_disk.storage.disk_id
  gateway_arn = aws_storagegateway_gateway.storage.arn
}

resource "aws_storagegateway_smb_file_share" "storage" {
  authentication = "GuestAccess"
  gateway_arn    = aws_storagegateway_gateway.storage.arn
  location_arn   = module.s3bucket.s3_bucket_arn
  role_arn       = module.iam-app-role.iamrole_arn
  tags           = local.tags
  kms_encrypted  = true
  kms_key_arn    = local.kms_key_arn
}
