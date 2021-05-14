
locals {
  dns_name = "${join("", aws_efs_file_system.default.*.id)}.efs.${var.region}.amazonaws.com"
}

resource "aws_efs_file_system" "default" {
  count                           = var.create ? 1 : 0
  encrypted                       = var.encrypted
  kms_key_id                      = local.kms_key_arn
  performance_mode                = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode
  tags = merge(
    local.tags,
    {
      "Name" = local.common_name
    }
  )

  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia == "" ? [] : [1]
    content {
      transition_to_ia = var.transition_to_ia
    }
  }
}

resource "aws_security_group" "efs" {
  count       = var.create ? 1 : 0
  name        = format("%s-efs", local.common_name)
  description = "EFS Security Group"
  vpc_id      = local.vpc_id
  tags        = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "egress" {
  count             = var.create ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.efs.*.id)
}

resource "aws_security_group_rule" "self_in" {
  security_group_id = join("", aws_security_group.efs.*.id)
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
}

resource "aws_security_group_rule" "self_out" {
  security_group_id = join("", aws_security_group.efs.*.id)
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
}

resource "aws_efs_mount_target" "default" {
  count           = var.create && length(local.subnet_ids) > 0 ? length(local.subnet_ids) : 0
  file_system_id  = join("", aws_efs_file_system.default.*.id)
  subnet_id       = local.subnet_ids[count.index]
  security_groups = [join("", aws_security_group.efs.*.id)]
}

resource "aws_efs_access_point" "data" {
  file_system_id = join("", aws_efs_file_system.default.*.id)
  tags = merge(
    local.tags,
    {
      "Name" = local.common_name
    }
  )
  root_directory {
    path = "/${local.jitbit_efs_configs["data_dir"]}"
    creation_info {
      owner_gid   = local.jitbit_efs_configs["group_gid"]
      owner_uid   = local.jitbit_efs_configs["user_uid"]
      permissions = local.jitbit_efs_configs["permissions"]
    }
  }

  posix_user {
    gid = local.jitbit_efs_configs["group_gid"]
    uid = local.jitbit_efs_configs["user_uid"]
  }
}
