locals {
  security_group_list = [
    aws_security_group.instance.id,
    aws_security_group.lb.id
  ]
}

resource "aws_security_group" "instance" {
  name        = format("%s-instance", local.common_name)
  description = "Instance Security Group"
  vpc_id      = local.vpc_id
  tags = merge(
    local.tags,
    {
      "Name" = format("%s-instance", local.common_name)
    },
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "lb" {
  name        = format("%s-lb", local.common_name)
  description = "App lb Security Group"
  vpc_id      = local.vpc_id
  tags = merge(
    local.tags,
    {
      "Name" = format("%s-lb", local.common_name)
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

# LB Rules
resource "aws_security_group_rule" "lb_to_jitbit" {
  security_group_id        = aws_security_group.lb.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  type                     = "egress"
  description              = "lb to jitbit"
  source_security_group_id = aws_security_group.instance.id
}


resource "aws_security_group_rule" "jitbit_from_lb" {
  security_group_id        = aws_security_group.instance.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "jitbit from lb"
  source_security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "vpn_to_instance" {
  security_group_id = aws_security_group.instance.id
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  type              = "ingress"
  description       = "vpn to jitbit instance"
  cidr_blocks       = local.vpn_source_cidrs
}

# DB Rules
resource "aws_security_group_rule" "db_out" {
  security_group_id        = aws_security_group.instance.id
  from_port                = 1433
  to_port                  = 1433
  protocol                 = "tcp"
  type                     = "egress"
  description              = "mssql"
  source_security_group_id = local.database_security_group_id
}

resource "aws_security_group_rule" "db_in" {
  security_group_id        = local.database_security_group_id
  from_port                = 1433
  to_port                  = 1433
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "mssql"
  source_security_group_id = aws_security_group.instance.id
}

# Misc
resource "aws_security_group_rule" "self_in" {
  count             = length(local.security_group_list)
  security_group_id = local.security_group_list[count.index]
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
  description       = "self_in"
}

resource "aws_security_group_rule" "self_out" {
  count             = length(local.security_group_list)
  security_group_id = local.security_group_list[count.index]
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
  description       = "self_out"
}

# SES and WorkMail
resource "aws_security_group_rule" "jitbit_ses_out" {
  security_group_id = aws_security_group.instance.id
  from_port         = 465
  to_port           = 465
  protocol          = "tcp"
  type              = "egress"
  description       = "SMTPS to SES for outbound email"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "jitbit_work_mail_out" {
  security_group_id = aws_security_group.instance.id
  from_port         = 993
  to_port           = 993
  protocol          = "tcp"
  type              = "egress"
  description       = "IMAPS to Workmail/Office365 for inbound email"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

# Justice office365 MailBox
resource "aws_security_group_rule" "jitbit_office365_out" {
  security_group_id = aws_security_group.instance.id
  from_port         = 587
  to_port           = 587
  protocol          = "tcp"
  type              = "egress"
  description       = "SMTPS to Office365 for outbound email"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

# ALb Access
resource "aws_security_group_rule" "application_access_https" {
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = concat(
    local.bastion_public_ip,
    var.cr_ancillary_admin_cidrs,
    var.cr_ancillary_access_cidrs,
    var.cr_ancillary_route53_healthcheck_access_cidrs,
    var.cr_jitbit_access_cidrs,
    local.natgateway_public_ip
  )
  ipv6_cidr_blocks = concat(
    var.cr_ancillary_route53_healthcheck_access_ipv6_cidrs
  )
  description = "Application Access - Https"
}

resource "aws_security_group_rule" "jitbit_to_lb" {
  security_group_id        = aws_security_group.lb.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "jitbit to lb"
  source_security_group_id = aws_security_group.instance.id
}

resource "aws_security_group_rule" "bastion_to_instance" {
  security_group_id = aws_security_group.instance.id
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = local.bastion_cidr_ranges
  description       = "ssh to jitbit instance"
}
