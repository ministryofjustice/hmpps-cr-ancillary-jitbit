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

variable "alarms_config" {
  type = object({
    enabled     = bool
    quiet_hours = tuple([number, number])
  })
  default = {
    enabled     = true
    quiet_hours = [23, 6]
  }
}
