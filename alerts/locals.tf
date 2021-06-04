locals {
  common_name                = data.terraform_remote_state.common.outputs.common_name
  sns_alarm_notification_arn = tostring(data.terraform_remote_state.monitoring.outputs.aws_sns_topic_alarm_notification["arn"])
}
