variable "common_name" {
  description = "common name used in reference to create resources"
}

variable "health_check_url" {
  description = "healthcheck endpoint"
}

variable "artifact_s3_location" {
  description = "synthetics artifact location"
}

variable "subnet_ids" {
  description = "private subnet id where to host synthetics lambda"
}

variable "lb_inbound_security_group_id" {
  description = "Load balancer inbound security group"
}

variable "lb_outbound_security_group_id" {
  description = "Load balancer inbound security group"
}

variable "tags" {
  description = "Applciation tags"
}