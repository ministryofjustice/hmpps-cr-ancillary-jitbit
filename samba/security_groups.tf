locals {
  security_group_list = [
    aws_security_group.samba.id,
    aws_security_group.storage_gateway.id,
    aws_security_group.lb.id
  ]
}

resource "aws_security_group" "samba" {
  name        = format("%s-samba-instance", local.common_name)
  description = "Samba Security Group"
  vpc_id      = local.vpc_id
  tags = merge(
    local.tags,
    {
      "Name" = format("%s-samba-instance", local.common_name)
    },
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "storage_gateway" {
  name        = format("%s-storage-gateway", local.common_name)
  description = "Storage gateway Security Group"
  vpc_id      = local.vpc_id
  tags = merge(
    local.tags,
    {
      "Name" = format("%s-storage-gateway", local.common_name)
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "lb" {
  name        = format("%s-storage-lb", local.common_name)
  description = "Storage lb Security Group"
  vpc_id      = local.vpc_id
  tags = merge(
    local.tags,
    {
      "Name" = format("%s-storage-lb", local.common_name)
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}


# LB Rules
resource "aws_security_group_rule" "lb_to_samba" {
  security_group_id        = aws_security_group.lb.id
  from_port                = 445
  to_port                  = 445
  protocol                 = "tcp"
  type                     = "egress"
  description              = "lb to samba"
  source_security_group_id = aws_security_group.samba.id
}


resource "aws_security_group_rule" "samba_from_lb" {
  security_group_id        = aws_security_group.samba.id
  from_port                = 445
  to_port                  = 445
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "samba from lb"
  source_security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "lb_to_samba_111" {
  security_group_id        = aws_security_group.lb.id
  from_port                = 111
  to_port                  = 111
  protocol                 = "tcp"
  type                     = "egress"
  description              = "lb to samba"
  source_security_group_id = aws_security_group.samba.id
}


resource "aws_security_group_rule" "samba_from_lb_111" {
  security_group_id        = aws_security_group.samba.id
  from_port                = 111
  to_port                  = 111
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "samba from lb"
  source_security_group_id = aws_security_group.lb.id
}

# EFS Rules
resource "aws_security_group_rule" "nfs_2049_out" {
  security_group_id        = aws_security_group.samba.id
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  type                     = "egress"
  description              = "efs"
  source_security_group_id = local.efs_security_group_id
}

resource "aws_security_group_rule" "nfs_2049_in" {
  security_group_id        = local.efs_security_group_id
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "efs"
  source_security_group_id = aws_security_group.samba.id
}

# Self rules

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
  security_group_id = aws_security_group.samba.id
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = local.bastion_cidr_ranges
  description       = "ssh"
}

# Storage Gateway 
resource "aws_security_group_rule" "gateway_http" {
  security_group_id = aws_security_group.storage_gateway.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  type              = "ingress"
  description       = "http"
  cidr_blocks       = var.jitbit_admin_cidrs
}

resource "aws_security_group_rule" "gateway" {
  security_group_id = aws_security_group.storage_gateway.id
  from_port         = 1026
  to_port           = 1031
  protocol          = "tcp"
  type              = "ingress"
  description       = "gateway"
  cidr_blocks       = [local.vpc_cidr_block]
}

resource "aws_security_group_rule" "ssh_alt" {
  security_group_id = aws_security_group.storage_gateway.id
  from_port         = 2222
  to_port           = 2222
  protocol          = "tcp"
  type              = "ingress"
  description       = "ssh alt"
  cidr_blocks       = [local.vpc_cidr_block]
}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.storage_gateway.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "ingress"
  description       = "https"
  cidr_blocks       = [local.vpc_cidr_block]
}

resource "aws_security_group_rule" "nfs_tcp" {
  security_group_id = aws_security_group.storage_gateway.id
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  type              = "ingress"
  description       = "nfs"
  cidr_blocks       = local.cidr_block
}

resource "aws_security_group_rule" "nfsv1_tcp" {
  security_group_id = aws_security_group.storage_gateway.id
  from_port         = 111
  to_port           = 111
  protocol          = "tcp"
  type              = "ingress"
  description       = "nfs"
  cidr_blocks       = local.cidr_block
}

resource "aws_security_group_rule" "nfsv3_tcp" {
  security_group_id = aws_security_group.storage_gateway.id
  from_port         = 20048
  to_port           = 20048
  protocol          = "tcp"
  type              = "ingress"
  description       = "nfs rule 2"
  cidr_blocks       = local.cidr_block
}

resource "aws_security_group_rule" "nfs_udp" {
  security_group_id = aws_security_group.storage_gateway.id
  from_port         = 2049
  to_port           = 2049
  protocol          = "udp"
  type              = "ingress"
  description       = "nfs"
  cidr_blocks       = local.cidr_block
}

resource "aws_security_group_rule" "nfsv1_udp" {
  security_group_id = aws_security_group.storage_gateway.id
  from_port         = 111
  to_port           = 111
  protocol          = "udp"
  type              = "ingress"
  description       = "nfs"
  cidr_blocks       = local.cidr_block
}

resource "aws_security_group_rule" "nfsv3_udp" {
  security_group_id = aws_security_group.storage_gateway.id
  from_port         = 20048
  to_port           = 20048
  protocol          = "udp"
  type              = "ingress"
  description       = "nfs rule 2"
  cidr_blocks       = local.cidr_block
}

resource "aws_security_group_rule" "dns" {
  security_group_id = aws_security_group.storage_gateway.id
  type              = "egress"
  from_port         = "53"
  to_port           = "53"
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "dns"
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.storage_gateway.id
  type              = "egress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ssh"
}

resource "aws_security_group_rule" "ntp" {
  security_group_id = aws_security_group.storage_gateway.id
  type              = "egress"
  from_port         = "123"
  to_port           = "123"
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ntp"
}

