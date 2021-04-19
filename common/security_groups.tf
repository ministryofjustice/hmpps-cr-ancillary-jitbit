resource "aws_security_group" "outbound" {
  name        = "${local.common_name}-internet-access"
  description = "security group for ${local.common_name}-access"
  vpc_id      = local.vpc_id
  tags = merge(
    local.tags,
    {
      "Name" = "${local.common_name}-internet"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}
