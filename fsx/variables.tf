variable "environment_name" {
  type = string
}

variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}
