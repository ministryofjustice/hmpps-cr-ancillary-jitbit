# CPU Utilization - Critical
resource "aws_cloudwatch_metric_alarm" "db_cpu_critical" {
  alarm_name          = "${local.common_name}_database_cpu--critical"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Database CPU averaging over 90, possible outage event."
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }
  
  tags                = local.tags
}

# CPU Utilization - Warning
resource "aws_cloudwatch_metric_alarm" "db_cpu_warning" {
  alarm_name          = "${local.common_name}_database_cpu--warning"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Database CPU averaging over 70, check for database."
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  tags                = local.tags
}

# CPUCreditBalance - Warning
resource "aws_cloudwatch_metric_alarm" "db_cpu_credit_balance" {
  alarm_name          = "${local.common_name}_database_cpu_credit_balance--warning"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUCreditBalance"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 100
  alarm_description   = "Average database CPU credit balance is too low, a negative performance impact is imminent."
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  tags                = local.tags
}

# DiskQueueDepth - Warning
resource "aws_cloudwatch_metric_alarm" "db_disk_queue_depth" {
  alarm_name          = "${local.common_name}_database_disk_queue_depth--warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 64
  alarm_description   = "Average database disk queue depth is too high, performance may be negatively impacted."
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  tags                = local.tags
}

# FreeStorageSpace - Critical
resource "aws_cloudwatch_metric_alarm" "db_free_storage_space_critical" {
  alarm_name          = "${local.common_name}_database_free_storage_space--critical"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 1000000000 //1 GB
  alarm_description   = "Average database free storage space is too low and may fill up soon."
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  tags                = local.tags
}

# FreeStorageSpace - Warning
resource "aws_cloudwatch_metric_alarm" "db_free_storage_space_warning" {
  alarm_name          = "${local.common_name}_database_free_storage_space--warning"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10000000000 //10 GB
  alarm_description   = "Average database free storage space is low and may fill up soon."
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  tags                = local.tags
}

# BurstBalance - Warning
resource "aws_cloudwatch_metric_alarm" "db_burst_balance" {
  alarm_name          = "${local.common_name}_database_burst_balance--warning"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BurstBalance"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Average database storage burst balance is too low, a negative performance impact is imminent."
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  tags                = local.tags
}

# FreeableMemory - Warning
resource "aws_cloudwatch_metric_alarm" "db_freeable_memory" {
  alarm_name          = "${local.common_name}_database_freeable_memory--warning"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 256000000 //256 MB
  alarm_description   = "Average database freeable memory is too low, performance may be negatively impacted."
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  tags                = local.tags
}

# DatabaseConnections - Warning
resource "aws_cloudwatch_metric_alarm" "db_connections" {
  alarm_name          = "${local.common_name}_database_connections--warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 200
  alarm_description   = "Average database connections over 200, check for database"
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  tags                = local.tags
}

# DatabaseConnections anomalous - Critical
resource "aws_cloudwatch_metric_alarm" "db_anomalous_connections" {
  alarm_name          = "${local.common_name}_database_anomalous_connections--critical"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 1
  threshold_metric_id = "e1"
  alarm_description   = "Anomalous database connection count detected. Something unusual is happening."
  alarm_actions       = [local.sns_alarm_notification_arn]
  ok_actions          = [local.sns_alarm_notification_arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 10)"
    label       = "DatabaseConnections (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "DatabaseConnections"
      namespace   = "AWS/RDS"
      period      = 600
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        DBInstanceIdentifier = local.db_instance_id
      }
    }
  }

  tags                = local.tags
}
