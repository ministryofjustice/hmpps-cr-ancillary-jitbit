variable "project_name" {
  description = "The project name - delius-core"
  type        = string
}

variable "public_dns_parent_zone" {
  type        = string
  description = "for strategic .gov domain. set in common.properties"
}
