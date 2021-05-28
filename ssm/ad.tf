# JitBit FSx AD Admins Password
resource "random_password" "ad_admin_password" {
  length  = 15
  special = false
}

resource "aws_ssm_parameter" "ad_admin_password" {
  name        = "/${var.common_name}/jitbit/ad/admin/password"
  description = "JITBIT FSx AD Admin Password"
  type        = "SecureString"
  value       = random_password.ad_admin_password.result

  tags = merge(
    var.tags,
    {
      "Name" = "/${var.common_name}/jitbit/ad/admin/password"
    },
  )

  lifecycle {
    ignore_changes = [value]
  }
}

# JitBit FSx AD Admins UserName
resource "aws_ssm_parameter" "ad_admin_username" {
  name        = "/${var.common_name}/jitbit/ad/admin/username"
  description = "JITBIT FSx AD Admin UserName"
  type        = "String"
  value       = "admin"

  tags = merge(
    var.tags,
    {
      "Name" = "/${var.common_name}/jitbit/ad/admin/username"
    },
  )
}
