variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "mail_account" {
  description = "office365 justice mail account"
  type        = list(string)
}