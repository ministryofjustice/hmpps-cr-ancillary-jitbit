locals {
  security_group_list = [
    aws_security_group.instance.id,
    aws_security_group.proxy.id,
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


resource "aws_security_group" "proxy" {
  name        = format("%s-proxy-lb", local.common_name)
  description = "Proxy lb Security Group"
  vpc_id      = local.vpc_id
  tags = merge(
    local.tags,
    {
      "Name" = format("%s-proxy-lb", local.common_name)
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

# LB Rules
resource "aws_security_group_rule" "lb_to_jitbit" {
  security_group_id        = aws_security_group.lb.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "egress"
  description              = "lb to jitbit"
  source_security_group_id = aws_security_group.instance.id
}


resource "aws_security_group_rule" "jitbit_from_lb" {
  security_group_id        = aws_security_group.instance.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "jitbit from lb"
  source_security_group_id = aws_security_group.lb.id
}

# Proxy
resource "aws_security_group_rule" "rdp_in" {
  security_group_id = aws_security_group.proxy.id
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  type              = "ingress"
  description       = "rdp"
  cidr_blocks       = var.jitbit_admin_cidrs
}

resource "aws_security_group_rule" "lb_to_rdp" {
  security_group_id        = aws_security_group.proxy.id
  from_port                = 3389
  to_port                  = 3389
  protocol                 = "tcp"
  type                     = "egress"
  description              = "lb to rdp"
  source_security_group_id = aws_security_group.instance.id
}


resource "aws_security_group_rule" "rdp_from_lb" {
  security_group_id        = aws_security_group.instance.id
  from_port                = 3389
  to_port                  = 3389
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "rdp from lb"
  source_security_group_id = aws_security_group.proxy.id
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

# Storage rules
resource "aws_security_group_rule" "samba_out" {
  security_group_id        = aws_security_group.instance.id
  from_port                = 445
  to_port                  = 445
  protocol                 = "tcp"
  type                     = "egress"
  description              = "samba"
  source_security_group_id = local.samba_security_group_id
}

resource "aws_security_group_rule" "samba_in" {
  security_group_id        = local.samba_security_group_id
  from_port                = 445
  to_port                  = 445
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "samba"
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
}

resource "aws_security_group_rule" "self_out" {
  count             = length(local.security_group_list)
  security_group_id = local.security_group_list[count.index]
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
}


# Bastion access
resource "aws_security_group_rule" "bastion" {
  security_group_id = aws_security_group.instance.id
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = local.bastion_cidr_ranges
  description       = "rdp"
}

# Bastion for foxy proxy
resource "aws_security_group_rule" "bastion_foxy_proxy" {
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = local.bastion_public_ip
  description       = "Bastion - Foxy Proxy"
}

# Enviornment User Access Eg: MOJ VPN
resource "aws_security_group_rule" "env_user_access" {
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = local.env_user_access_cidr_blocks
  description       = "Env User Access"
}