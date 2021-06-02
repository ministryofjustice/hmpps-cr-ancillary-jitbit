# IIS HttpErr log Metrics
resource "aws_cloudwatch_log_metric_filter" "iis_httperr_metrics" {
  name           = "IIS_AppPool"
  pattern        = "AppOffline"
  log_group_name = aws_cloudwatch_log_group.iis_httperr_metrics.name

  metric_transformation {
    name      = "AppPool"
    namespace = "IIS"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_group" "iis_httperr_metrics" {
  name = "${local.common_name}/*/iis/httpErr"
}

# General Instance check 
