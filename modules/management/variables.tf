variable "common" {
  description = "Holds configuration details"
}

variable "listener_arn" {
  description = "arn of loadbalancer listener"
}

variable "failover_lambda_enable" {
  description = "enable failover lambda"
  default     = "true"
}
