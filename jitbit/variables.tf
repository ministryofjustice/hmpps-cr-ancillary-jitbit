variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "cr_jitbit_configs" {
  type = map(any)
  default = {
    cookie_duration           = "3600"
    system_ssm_user           = "/cr-ancillary/jitbit/system/common/user/jitbit/user"
    system_ssm_password       = "/cr-ancillary/jitbit/system/common/user/jitbit/password"
    instance_type             = "m4.xlarge"
    volume_size               = "100"
    asg_min_size              = 1
    asg_max_size              = 1
    asg_capacity              = 1
    health_check_type         = "ELB"
    min_elb_capacity          = "1"
    wait_for_capacity_timeout = "10m"
    health_check_grace_period = "300"
    cache_disk_size           = "200"
    cache_iops                = "0"
    cache_device_name         = "/dev/xvdb"
    cache_volume_type         = "standard"
  }
}

variable "cr_jitbit_overrides" {
  type    = map(any)
  default = {}
}

variable "metrics_granularity" {
  default = "1Minute"
}

variable "enabled_metrics" {
  type = list(string)
  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
}

variable "jitbit_admin_cidrs" {
  type    = list(any)
  default = []
}

variable "jitbit_access_cidrs" {
  type    = list(any)
  default = []
}

variable "jitbit_route53_healthcheck_access_cidrs" {
  type    = list(any)
  default = []
}

variable "jitbit_route53_healthcheck_access_ipv6_cidrs" {
  type    = list(any)
  default = []
}

variable "bastion_remote_state_bucket_name" {
  description = "Terraform remote state bucket name for Bastion VPC"
}

variable "bastion_role_arn" {
  description = "role to access bastion terraform state"
}

variable "env_user_access_cidr_blocks" {
  type = list(string)
}
