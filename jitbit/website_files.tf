data "template_file" "appsettings" {
  template = file("./files/appsettings.json")
  vars = {
    app_url          = aws_route53_record.jitbit.name
    db_source        = local.database_address
    db_user_id       = data.aws_ssm_parameter.db_user_id.value
    db_user_password = data.aws_ssm_parameter.db_user_password.value
  }
}

resource "aws_s3_bucket_object" "appsettings" {
  bucket  = local.common_name
  key     = "/${local.installer_files_s3_prefix}/HelpDesk/appsettings.json"
  content = data.template_file.appsettings.rendered
}
