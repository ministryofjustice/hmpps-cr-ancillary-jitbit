# Workmail Office User Password
resource "random_password" "workmail_office_user_password" {
  length  = 15
  special = false
}

resource "aws_ssm_parameter" "workmail_office_user_password" {
  name        = "/${local.common_name}/jitbit/workmail/office/user/password"
  description = "JITBIT Workmail Office User Password"
  type        = "SecureString"
  value       = random_password.workmail_office_user_password.result

  tags = merge(
    local.tags,
    {
      "Name" = "/${local.common_name}/jitbit/workmail/office/user/password"
    },
  )

  lifecycle {
    ignore_changes = [value]
  }
}

# Workmail Office UserName
# In Prod additonal user office2 and office3 created for testing
resource "aws_ssm_parameter" "workmail_office_user_name" {
  name        = "/${local.common_name}/jitbit/workmail/office/user/username"
  description = "JITBIT Workmail Office UserName"
  type        = "String"
  value       = "office"

  tags = merge(
    local.tags,
    {
      "Name" = "/${local.common_name}/jitbit/workmail/office/user/username"
    },
  )
}

resource "aws_ssm_parameter" "office365_user_password" {
  count       = lenght(var.mail_account) && local.common_name == "cr-jitbit-prod" ? 1 : 0
  name        = "/${local.common_name}/jitbit/office365/${var.mail_account[count.index]}/user/password"
  description = "JITBIT office365 ${var.mail_account[count.index]} User Password"
  type        = "SecureString"
  value       = random_password.workmail_office_user_password.result

  tags = merge(
    local.tags,
    {
      "Name" = "/${local.common_name}/jitbit/office365/${var.mail_account[count.index]}/user/password"
    },
  )

  lifecycle {
    ignore_changes = [value]
  }
}
