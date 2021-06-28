resource "aws_synthetics_canary" "synthetics" {
  name                 = local.common_name
  execution_role_arn   = aws_iam_role.synthetics.arn
  handler              = "index.handler"
  zip_file             = filebase64sha256(data.archive_file.synthetics.output_path)
  runtime_version      = "syn-python-selenium-1.0"

  schedule {
    expression = "rate(15 minute)"
  }
}
