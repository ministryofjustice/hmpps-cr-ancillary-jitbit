################################################################################
# IAM Role for Windows Authentication
################################################################################

data "aws_iam_policy_document" "rds_assume_role" {
  statement {
    sid = "AssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_iam_role" {
  name                  = "${local.common_name}-rds"
  description           = "Role used by RDS for authentication and authorization"
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.rds_assume_role.json

  tags = local.tags
}


################################################################################
# Create an IAM role to allow enhanced monitoring
################################################################################

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name_prefix        = "${local.common_name}-rds-monitoring-"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_security_group" "rds" {
  count       = var.create ? 1 : 0
  name        = format("%s-rds", local.common_name)
  description = "RDS Security Group"
  vpc_id      = local.vpc_id
  tags        = local.tags

  lifecycle {
    create_before_destroy = true
  }
}
