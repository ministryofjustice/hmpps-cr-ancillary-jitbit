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

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.outbound.id
  type              = "egress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.common_name}-http"
  count             = var.create_outbound_web_rules
}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.outbound.id
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.common_name}-https"
  count             = var.create_outbound_web_rules
}
