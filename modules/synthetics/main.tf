resource "aws_synthetics_canary" "synthetics" {
  name                 = var.common_name
  artifact_s3_location = var.artifact_s3_location
  execution_role_arn   = aws_iam_role.synthetics.arn
  handler              = "pageLoadBlueprint.handler"
  zip_file             = data.archive_file.synthetics.output_path
  runtime_version      = "syn-python-selenium-1.0"

  vpc_config {
    security_group_ids = [
     var.lb_inbound_security_group_id,
     var.lb_outbound_security_group_id
    ]
    subnet_ids = flatten(var.subnet_ids)
  }

  schedule {
    expression = "rate(15 minutes)"
  }
  tags = var.tags
}
