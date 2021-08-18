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

module "db_subnet_group" {
  source          = "../modules/rds/db_subnet_group"
  create          = true
  name            = format("%s-subnet", local.common_name)
  use_name_prefix = true
  description     = "RDS Subnet Group"
  subnet_ids      = local.subnet_ids
  tags            = local.tags
}

module "db_parameter_group" {
  source          = "../modules/rds/db_parameter_group"
  create          = true
  name            = format("%s-param", local.common_name)
  use_name_prefix = true
  description     = "RDS Parameter Group"
  family          = local.cr_jitbit_rds_options["family"]
  parameters      = var.jitbit_parameters
  tags            = local.tags
}

module "db_option_group" {
  source                   = "../modules/rds/db_option_group"
  create                   = true
  name                     = format("%s-opt", local.common_name)
  use_name_prefix          = true
  option_group_description = "RDS Option Group"
  engine_name              = local.cr_jitbit_rds_options["engine"]
  major_engine_version     = local.cr_jitbit_rds_options["major_engine_version"]
  options                  = var.jitbit_options
  timeouts                 = var.jitbit_option_group_timeouts
  tags                     = local.tags
}

module "db_instance" {
  source = "../modules/rds/db_instance"

  create     = true
  identifier = format("%s-db", local.common_name)

  engine            = local.cr_jitbit_rds_options["engine"]
  engine_version    = local.cr_jitbit_rds_options["engine_version"]
  instance_class    = local.cr_jitbit_rds_options["instance_class"]
  allocated_storage = local.cr_jitbit_rds_options["allocated_storage"]
  storage_type      = local.cr_jitbit_rds_options["storage_type"]
  storage_encrypted = true
  kms_key_id        = local.kms_key_arn
  license_model     = "license-included"

  name                                = local.db_name
  username                            = local.db_user_name
  password                            = local.db_password
  port                                = 1433
  iam_database_authentication_enabled = false

  vpc_security_group_ids = aws_security_group.rds.*.id
  db_subnet_group_name   = module.db_subnet_group.this_db_subnet_group_id
  parameter_group_name   = module.db_parameter_group.this_db_parameter_group_id
  option_group_name      = module.db_option_group.this_db_option_group_id

  availability_zone   = null
  multi_az            = var.disable_multi_az || var.jitbit_data_import == true ? false : true
  iops                = local.cr_jitbit_rds_options["iops"]
  publicly_accessible = false
  ca_cert_identifier  = null

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false
  apply_immediately           = false
  maintenance_window          = local.cr_jitbit_rds_options["maintenance_window"]

  snapshot_identifier              = local.cr_jitbit_rds_options["snapshot_identifier"]
  copy_tags_to_snapshot            = true
  skip_final_snapshot              = false
  final_snapshot_identifier        = format("%s-snapshot", local.common_name)
  final_snapshot_identifier_prefix = "final"

  performance_insights_kms_key_id       = local.kms_key_arn
  performance_insights_enabled          = true
  performance_insights_retention_period = local.cr_jitbit_rds_options["performance_insights_retention_period"]

  replicate_source_db     = null
  backup_retention_period = var.disable_multi_az || var.jitbit_data_import == true ? 0 : local.cr_jitbit_rds_options["backup_retention_period"]
  backup_window           = local.cr_jitbit_rds_options["backup_window"]
  max_allocated_storage   = local.cr_jitbit_rds_options["max_allocated_storage"]
  monitoring_interval     = local.cr_jitbit_rds_options["monitoring_interval"]
  monitoring_role_arn     = aws_iam_role.rds_enhanced_monitoring.arn
  monitoring_role_name    = aws_iam_role.rds_enhanced_monitoring.name
  create_monitoring_role  = false

  character_set_name              = local.cr_jitbit_rds_options["character_set_name"]
  timezone                        = local.cr_jitbit_rds_options["timezone"]
  enabled_cloudwatch_logs_exports = var.jitbit_enabled_cloudwatch_logs_exports

  timeouts = var.jitbit_timeouts

  deletion_protection      = false
  delete_automated_backups = true
  tags                     = local.tags
}
