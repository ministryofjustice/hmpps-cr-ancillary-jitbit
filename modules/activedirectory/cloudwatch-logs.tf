resource "aws_cloudwatch_log_group" "active_directory" {
  name              = "/aws/directoryservice/${aws_directory_service_directory.active_directory.id}"
  retention_in_days = 14
}

data "aws_iam_policy_document" "ad-log-policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    principals {
      identifiers = ["ds.amazonaws.com"]
      type        = "Service"
    }

    resources = ["${aws_cloudwatch_log_group.active_directory.arn}:*"]

    effect = "Allow"
  }
}

resource "aws_cloudwatch_log_resource_policy" "active_directory-log-policy" {
  policy_document = data.aws_iam_policy_document.ad-log-policy.json
  policy_name     = "ad-log-policy"
}

resource "aws_directory_service_log_subscription" "active_directory" {
  directory_id   = aws_directory_service_directory.active_directory.id
  log_group_name = aws_cloudwatch_log_group.active_directory.name
}
