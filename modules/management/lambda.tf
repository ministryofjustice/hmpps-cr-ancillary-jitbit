resource "aws_lambda_function" "mgmt" {
  runtime          = "python3.8"
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.lambda_handler_zip.output_path
  function_name    = "${var.common["common_name"]}-mgmt-canary"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.lambda_handler_zip.output_path)
  environment {
    variables = {
      enable       = "true"
      listener_arn = var.listener_arn
    }
  }
}

resource "aws_cloudwatch_log_group" "mgmt" {
  name              = "/aws/lambda/${var.common["common_name"]}-mgmt-canary"
  retention_in_days = 14
}

resource "aws_lambda_permission" "mgmt" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mgmt.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.mgmt_notification.arn
}
