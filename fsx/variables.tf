variable "environment_name" {
  type = string
}

variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "storage_capacity" {
  description = "Storage capacity for FSx file system"
  default     = 32 # GiB
}

variable "throughput_capacity" {
  description = "Throughput capacity for FSx file system"
  default     = 8 # MB/s
}
