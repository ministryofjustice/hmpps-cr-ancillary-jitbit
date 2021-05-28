# Workmail Office User Password
resource "random_password" "workmail_office_user_password" {
  length  = 15
  special = false
}

resource "aws_ssm_parameter" "workmail_office_user_password" {
  name        = "/${var.common_name}/jitbit/workmail/office/user/password"
  description = "JITBIT Workmail Office User Password"
  type        = "SecureString"
  value       = random_password.workmail_office_user_password.result

  tags = merge(
    var.tags,
    {
      "Name" = "/${var.common_name}/jitbit/workmail/office/user/password"
    },
  )

  lifecycle {
    ignore_changes = [value]
  }
}

# Workmail Office UserName
# In Prod additonal user office2 and office3 created for testing
resource "aws_ssm_parameter" "workmail_office_user_name" {
  name        = "/${var.common_name}/jitbit/workmail/office/user/username"
  description = "JITBIT Workmail Office UserName"
  type        = "String"
  value       = "office"

  tags = merge(
    var.tags,
    {
      "Name" = "/${var.common_name}/jitbit/workmail/office/user/username"
    },
  )
}
