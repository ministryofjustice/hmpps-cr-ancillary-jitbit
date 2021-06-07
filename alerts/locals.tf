locals {
  common_name                = data.terraform_remote_state.common.outputs.common_name
  sns_alarm_notification_arn = data.terraform_remote_state.monitoring.outputs.aws_sns_topic_alarm_notification["arn"]
  jitbit                     = data.terraform_remote_state.jitbit.outputs.jitbit
}
