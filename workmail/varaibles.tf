variable "environment_type" {
  description = "The environment type - e.g. dev"
  type        = string
}

variable "project_name" {
  description = "The project name - delius-core"
  type        = string
}

variable "public_dns_parent_zone" {
  type        = string
  description = "for strategic .gov domain. set in common.properties"
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}
