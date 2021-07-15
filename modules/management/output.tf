output "aws_sns_topic_mgmt_notification" {
  value = {
    arn  = aws_sns_topic.mgmt_notification.arn
    name = aws_sns_topic.mgmt_notification.name
  }
}
