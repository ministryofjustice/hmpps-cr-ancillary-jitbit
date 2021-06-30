# By Default canary are in stop status after creation need to be started
resource "aws_synthetics_canary" "synthetics" {
  name                 = var.common["environment_name"]
  artifact_s3_location = var.synthetics["artifact_s3_location"]
  execution_role_arn   = aws_iam_role.synthetics.arn
  handler              = "pageLoadBlueprint.handler"
  zip_file             = data.archive_file.synthetics.output_path
  runtime_version      = "syn-python-selenium-1.0"

  vpc_config {
    security_group_ids = [
      var.synthetics["inbound_security_group_id"],
      var.synthetics["outbound_security_group_id"]
    ]
    subnet_ids = flatten(var.synthetics["subnet_ids"])
  }

  schedule {
    expression = "rate(1 hour)"
  }

  tags = merge(
    var.common["tags"],
    {
      "Name" = var.common["environment_name"]
    }
  )

}
