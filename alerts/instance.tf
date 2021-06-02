# IIS HttpErr log Metrics
resource "aws_cloudwatch_log_metric_filter" "iis_httperr_metrics" {
  name           = "IIS_AppPool"
  pattern        = "AppOffline"
  log_group_name = "${local.common_name}"

  metric_transformation {
    name      = "AppPool"
    namespace = "IIS"
    value     = "1"
  }
}

# General Instance check 
