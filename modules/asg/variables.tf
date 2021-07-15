variable "common" {
  description = "Holds configuration details"
}

variable "canary" {
  description = "canary configuration details"
}

variable "name" {
  description = "canary name"
  default     = "blue"
}

variable "subnet_ids" {
  description = "id of the subnet where the instance need to be spin up"
}
