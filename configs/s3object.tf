# Cloudwatch config - Active
data "template_file" "cloudwatch_config" {
  template = file("./files/config.json")
  vars = {
    log_group_name = local.common_name
    asg_group_name = local.jitbit["autoscaling_group_name"]
  }
}

resource "aws_s3_bucket_object" "cloudwatch_config" {
  bucket  = local.common_name
  key     = "/cloudwatch/config.json"
  content = data.template_file.cloudwatch_config.rendered
}

# Cloudwatch config - Passive
data "template_file" "passive_cloudwatch_config" {
  template = file("./files/config.json")
  vars = {
    log_group_name = local.common_name
    asg_group_name = local.jitbit["passive_autoscaling_group_name"]
  }
}

resource "aws_s3_bucket_object" "passive_cloudwatch_config" {
  bucket  = local.common_name
  key     = "/cloudwatch/passive_config.json"
  content = data.template_file.passive_cloudwatch_config.rendered
}

# Logrotate config
data "template_file" "logrotate_config" {
  template = file("./files/iis_log_rotation.xml")
  vars = {
    ad_name = local.common_name
  }
}

resource "aws_s3_bucket_object" "logrotate_config" {
  bucket  = local.common_name
  key     = "/mgmt/iis_log_rotation.xml"
  content = data.template_file.logrotate_config.rendered
}

# Logrotate Script
data "template_file" "logrotate_script" {
  template = file("./files/logrotate.ps1")
}

resource "aws_s3_bucket_object" "logrotate_script" {
  bucket  = local.common_name
  key     = "/mgmt/logrotate.ps1"
  content = data.template_file.logrotate_script.rendered
}
