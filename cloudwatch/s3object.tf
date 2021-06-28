data "template_file" "cloudwatch_config" {
  template = file("./files/config.json")
  vars = {
    log_group_name = local.common_name
  }
}

resource "aws_s3_bucket_object" "cloudwatch_config" {
  bucket  = local.common_name
  key     = "/cloudwatch/config.json"
  content = data.template_file.cloudwatch_config.rendered
}
