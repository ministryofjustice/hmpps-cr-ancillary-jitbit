variable "region" {
  description = "The AWS region."
}

variable "lb_account_id" {
}

variable "role_arn" {
}

variable "short_environment_name" {
  description = "short resource label or name"
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "create_outbound_web_rules" {
  default = 1
}

variable "cr_log_retention_days" {
  default = 14
}

variable "bastion_remote_state_bucket_name" {
  description = "Terraform remote state bucket name for bastion vpc"
}

variable "bastion_role_arn" {
  description = "arn to use for bastion terraform"
}
