data "aws_caller_identity" "current" {
}

data "archive_file" "lambda_handler_zip" {
  type        = "zip"
  output_path = "${path.module}/files/${var.common["environment_name"]}-mgmt-canary.zip"
  source {
    content  = file("${path.module}/lambda/lambda_function.py")
    filename = "lambda_function.py"
  }
}
