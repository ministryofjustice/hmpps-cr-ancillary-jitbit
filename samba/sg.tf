resource "aws_security_group" "samba" {
  name        = format("%s-samba", local.common_name)
  description = "Samba Security Group"
  vpc_id      = local.vpc_id
  tags        = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "storage" {
  name        = format("%s-storage", local.common_name)
  description = "storage Security Group"
  vpc_id      = local.vpc_id
  tags        = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "self_in" {
  security_group_id = aws_security_group.samba.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
}

resource "aws_security_group_rule" "self_out" {
  security_group_id = aws_security_group.samba.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
}


resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.samba.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  type              = "ingress"
  description       = "http"
  cidr_blocks       = [local.vpc_cidr_block]
}

resource "aws_security_group_rule" "gateway" {
  security_group_id = aws_security_group.storage.id
  from_port         = 1026
  to_port           = 1031
  protocol          = "tcp"
  type              = "ingress"
  description       = "gateway"
  cidr_blocks       = [local.vpc_cidr_block]
}

resource "aws_security_group_rule" "ssh_alt" {
  security_group_id = aws_security_group.storage.id
  from_port         = 2222
  to_port           = 2222
  protocol          = "tcp"
  type              = "ingress"
  description       = "ssh alt"
  cidr_blocks       = [local.vpc_cidr_block]
}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.storage.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "ingress"
  description       = "https"
  cidr_blocks       = [local.vpc_cidr_block]
}

resource "aws_security_group_rule" "nfs_tcp" {
  security_group_id = aws_security_group.samba.id
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  type              = "ingress"
  description       = "nfs"
  cidr_blocks       = local.cidr_block
}

resource "aws_security_group_rule" "nfsv1_tcp" {
  security_group_id = aws_security_group.samba.id
  from_port         = 111
  to_port           = 111
  protocol          = "tcp"
  type              = "ingress"
  description       = "nfs"
  cidr_blocks       = local.cidr_block
}

resource "aws_security_group_rule" "nfsv3_tcp" {
  security_group_id = aws_security_group.samba.id
  from_port         = 20048
  to_port           = 20048
  protocol          = "tcp"
  type              = "ingress"
  description       = "nfs rule 2"
  cidr_blocks       = local.cidr_block
}

resource "aws_security_group_rule" "nfs_udp" {
  security_group_id = aws_security_group.samba.id
  from_port         = 2049
  to_port           = 2049
  protocol          = "udp"
  type              = "ingress"
  description       = "nfs"
  cidr_blocks       = local.cidr_block
}

resource "aws_security_group_rule" "nfsv1_udp" {
  security_group_id = aws_security_group.samba.id
  from_port         = 111
  to_port           = 111
  protocol          = "udp"
  type              = "ingress"
  description       = "nfs"
  cidr_blocks       = local.cidr_block
}

resource "aws_security_group_rule" "nfsv3_udp" {
  security_group_id = aws_security_group.samba.id
  from_port         = 20048
  to_port           = 20048
  protocol          = "udp"
  type              = "ingress"
  description       = "nfs rule 2"
  cidr_blocks       = local.cidr_block
}

resource "aws_security_group_rule" "dns" {
  security_group_id = aws_security_group.samba.id
  type              = "egress"
  from_port         = "53"
  to_port           = "53"
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "dns"
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.samba.id
  type              = "egress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ssh"
}

resource "aws_security_group_rule" "ntp" {
  security_group_id = aws_security_group.samba.id
  type              = "egress"
  from_port         = "123"
  to_port           = "123"
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ntp"
}
