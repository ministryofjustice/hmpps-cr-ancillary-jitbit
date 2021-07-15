resource "aws_sns_topic" "mgmt_notification" {
  name = "${var.common["common_name"]}-mgmt-notification"
}

resource "aws_sns_topic_subscription" "mgmt_subscription" {
  protocol  = "lambda"
  topic_arn = aws_sns_topic.mgmt_notification.arn
  endpoint  = aws_lambda_function.mgmt.arn
}
