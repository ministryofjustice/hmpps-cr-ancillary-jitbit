data "template_file" "webconfig" {
  template = file("./files/Web.config")
  vars = {
    app_url          = aws_route53_record.dns_entry.name
    db_source        = local.database_endpoint
    db_user_id       = data.aws_ssm_parameter.db_user_id.name
    db_user_password = data.aws_ssm_parameter.db_user_password.name
  }
}

resource "aws_s3_bucket_object" "webconfig" {
  bucket  = local.common_name
  key     = "/installers/HelpDesk/Web.config"
  content = data.template_file.webconfig.rendered
}
