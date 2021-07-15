data "template_file" "webconfig" {
  template = file("./files/Web.config")
  vars = {
    app_url          = aws_route53_record.jitbit.name
    db_source        = local.database_address
    db_user_id       = data.aws_ssm_parameter.db_user_id.value
    db_user_password = data.aws_ssm_parameter.db_user_password.value
  }
}

resource "aws_s3_bucket_object" "webconfig" {
  bucket  = local.common_name
  key     = "/installers/HelpDesk/Web.config"
  content = data.template_file.webconfig.rendered
}
