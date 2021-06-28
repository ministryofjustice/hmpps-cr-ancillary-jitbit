resource "aws_synthetics_canary" "synthetics" {
  name                 = var.common_name
  artifact_s3_location = var.artifact_s3_location
  execution_role_arn   = aws_iam_role.synthetics.arn
  handler              = "index.handler"
  zip_file             = data.archive_file.synthetics.output_path
  runtime_version      = "syn-python-selenium-1.0"

  schedule {
    expression = "rate(15 minute)"
  }
}
