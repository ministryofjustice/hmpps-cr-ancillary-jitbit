data "template_file" "kms" {
  template = file("../policies/cloudwatch.kms.json")

  vars = {
    region     = local.region
    account_id = local.account_id
  }
}

resource "aws_kms_key" "kms" {
  description             = "${local.common_name}_logs"
  deletion_window_in_days = 14
  is_enabled              = true
  enable_key_rotation     = true
  policy                  = data.template_file.kms.rendered
  tags = merge(
    local.tags,
    {
      "Name" = "${local.common_name}_logs"
    },
  )
}

resource "aws_kms_alias" "kms" {
  name          = "alias/${local.common_name}_logs"
  target_key_id = aws_kms_key.kms.key_id
}
