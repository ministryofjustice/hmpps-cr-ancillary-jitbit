resource "aws_cloudwatch_log_group" "logs" {
  name              = local.common_name
  retention_in_days = var.cr_log_retention_days
  kms_key_id        = aws_kms_key.kms.arn
  tags              = local.tags
}
