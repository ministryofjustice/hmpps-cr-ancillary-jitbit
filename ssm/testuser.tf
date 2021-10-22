# JitBit Test user
resource "random_password" "jitbit_testuser_password" {
  length  = 15
  special = false
}

# JitBit Test user Password
resource "aws_ssm_parameter" "jitbit_testuser_password" {
  name        = "/${local.common_name}/jitbit/test/jitbit_test_password"
  description = "JitBit Test user Password"
  type        = "SecureString"
  value       = random_password.jitbit_testuser_password.result

  tags = merge(
    local.tags,
    {
      "Name" = "/${local.common_name}/jitbit/test/jitbit_test_password"
    },
  )

  lifecycle {
    ignore_changes = [value]
  }
}

# JitBit Test user UserName
resource "aws_ssm_parameter" "jitbit_testuser_username" {
  name        = "/${local.common_name}/jitbit/test/jitbit_test_username"
  description = "JitBit Test user UserName"
  type        = "String"
  value       = "jitbit.testuser"

  tags = merge(
    local.tags,
    {
      "Name" = "/${local.common_name}/jitbit/test/jitbit_test_username"
    },
  )
}
