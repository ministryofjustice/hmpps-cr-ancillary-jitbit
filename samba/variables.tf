variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "s3_lifecycle_config" {
  type = map(string)
  default = {
    noncurrent_version_transition_days         = 30
    noncurrent_version_transition_glacier_days = 60
    noncurrent_version_expiration_days         = 90
  }
}

variable "bastion_inventory" {
  default = "dev"
}

variable "jitbit_samba_configs" {
  type = map
  default = {
    instance_type             = "m4.xlarge"
    volume_size               = "100"
    cache_disk_size           = "50"
    cache_iops                = "0"
    cache_device_name         = "/dev/xvdb"
    cache_volume_type         = "standard"
    asg_min_size              = 1
    asg_max_size              = 1
    asg_capacity              = 1
    cookie_duration           = "3600"
    health_check_type         = "ELB"
    min_elb_capacity          = "1"
    wait_for_capacity_timeout = "10m"
    health_check_grace_period = "300"
    samba_ssm_user            = "/cr-ancillary/jitbit/samba/share/jitbit/user"
    samba_ssm_password        = "/cr-ancillary/jitbit/samba/share/jitbit/password"
    samba_share               = "/opt/jitbit"
  }
}

variable "jitbit_samba_overrides" {
  type    = map
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

variable "source_code_versions" {
  type = map(string)
  default = {
    boostrap        = "centos"
    samba           = "master"
    samba_bootstrap = "master"
  }
}
