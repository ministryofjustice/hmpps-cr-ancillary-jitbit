variable "s3_bucket_name" {}

variable "acl" {
  default = "private"
}

variable "tags" {
  type = "map"
}

variable "target_bucket" {
  description = "logs target_bucket"
}

variable "target_prefix" {
  description = "logs target_prefix"
  default     = "/log"
}

variable "kms_master_key_id" {
  description = "kms master key id"
}

variable "sse_algorithm" {
  default = "aws:kms"
}

variable "versioning" {
  default = false
}

variable "s3_lifecycle_config" {
  type = "map"
}

variable "block_public_acls" {
  type    = bool
  default = true
}

variable "block_public_policy" {
  type    = bool
  default = true
}

variable "ignore_public_acls" {
  type    = bool
  default = true
}

variable "restrict_public_buckets" {
  type    = bool
  default = true
}
