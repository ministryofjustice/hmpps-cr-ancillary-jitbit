# RDS Admins Password
resource "random_password" "rds_admin_password" {
  length  = 20
  special = false
}

resource "aws_ssm_parameter" "rds_admin_password" {
  name        = "/${local.common_name}/jitbit/rds/admin/password"
  description = "JITBIT RDS Admin Password"
  type        = "SecureString"
  value       = random_password.rds_admin_password.result

  tags = merge(
    local.tags,
    {
      "Name" = "/${local.common_name}/jitbit/rds/admin/password"
    },
  )

  lifecycle {
    ignore_changes = [value]
  }
}

# RDS Admins Username
resource "aws_ssm_parameter" "rds_admin_username" {
  name        = "/${local.common_name}/jitbit/rds/admin/username"
  description = "JITBIT RDS Admin UserName"
  type        = "String"
  value       = "admin"

  tags = merge(
    local.tags,
    {
      "Name" = "/${local.common_name}/jitbit/rds/admin/username"
    },
  )
}

# RDS JitBit User Password
resource "random_password" "rds_jitbit_user_password" {
  length  = 20
  special = false
}

resource "aws_ssm_parameter" "rds_jitbit_user_password" {
  name        = "/${local.common_name}/jitbit/rds/jitbit/user/password"
  description = "JITBIT RDS JitBit User Password"
  type        = "SecureString"
  value       = random_password.rds_jitbit_user_password.result

  tags = merge(
    local.tags,
    {
      "Name" = "/${local.common_name}/jitbit/rds/jitbit/user/password"
    },
  )

  lifecycle {
    ignore_changes = [value]
  }
}

# RDS JitBit User UserName
resource "aws_ssm_parameter" "rds_jitbit_user_username" {
  name        = "/${local.common_name}/jitbit/rds/jitbit/user/username"
  description = "JITBIT RDS User UserName"
  type        = "String"
  value       = "jitbit"

  tags = merge(
    local.tags,
    {
      "Name" = "/${local.common_name}/jitbit/rds/jitbit/user/username"
    },
  )

  lifecycle {
    ignore_changes = [value]
  }
}