variable "environment_name" {
  type = string
}

variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "create" {
  default     = true
  description = "If `false`, this module does nothing"
  type        = bool
}

# https://aws.amazon.com/blogs/aws/amazon-rds-maintenance-windows-shortened/
variable "cr_jitbit_rds_config" {
  type = map(any)
  default = {
    credentials_ssm_path                  = "/cr-ancillary/jitbit/rds/database/db/admin"
    family                                = "sqlserver-se-15.0"
    engine                                = "sqlserver-se"
    major_engine_version                  = "15.00"
    engine_version                        = "15.00.4073.23.v1"
    instance_class                        = "db.t3.xlarge"
    allocated_storage                     = "100"
    max_allocated_storage                 = "200"
    storage_type                          = "gp2"
    iops                                  = "0"
    snapshot_identifier                   = ""
    performance_insights_retention_period = "7"
    backup_retention_period               = "14"
    backup_window                         = "17:30-18:00"
    maintenance_window                    = "Sat:01:30-Sat:02:00"
    character_set_name                    = "Latin1_General_CI_AS"
    timezone                              = "GMT Standard Time"
    monitoring_interval                   = "60"
  }
}

variable "cr_jitbit_rds_overrides" {
  type    = map(any)
  default = {}
}

variable "jitbit_parameters" {
  description = "A list of DB parameters (map) to apply"
  type        = list(map(string))
  default     = []
}

variable "jitbit_options" {
  description = "A list of Options to apply."
  type        = any
  default     = []
}

variable "jitbit_option_group_timeouts" {
  description = "Define maximum timeout for deletion of `aws_db_option_group` resource"
  type        = map(string)
  default = {
    delete = "15m"
  }
}

variable "jitbit_enabled_cloudwatch_logs_exports" {
  type = list(any)
  default = [
    "error"
  ]
}

variable "jitbit_data_import" {
  type    = bool
  default = false
}

variable "jitbit_timeouts" {
  description = "(Optional) Updated Terraform resource management timeouts. Applies to `aws_db_instance` in particular to permit resource management times"
  type        = map(string)
  default = {
    create = "60m"
    update = "80m"
    delete = "60m"
  }
}

variable "rds_stop_resources_tag_phase1" {
  description = "Autostop tag value used by lambda to stop RDS instances"
  default     = "disable"
}

variable "disable_multi_az" {
  type    = bool
  default = false
}