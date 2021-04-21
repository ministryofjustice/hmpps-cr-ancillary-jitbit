
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
