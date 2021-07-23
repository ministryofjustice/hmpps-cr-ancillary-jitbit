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
