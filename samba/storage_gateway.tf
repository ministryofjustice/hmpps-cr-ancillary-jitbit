resource "aws_vpc_endpoint" "storage" {
  vpc_id              = local.vpc_id
  service_name        = "com.amazonaws.${var.region}.storagegateway"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = false
  security_group_ids = [
    aws_security_group.storage.id,
    data.terraform_remote_state.common.outputs.sg_outbound_id
  ]
  tags = merge(
    local.tags,
    { "Name" : "${local.common_name}-storage-gateway" }
  )
}
