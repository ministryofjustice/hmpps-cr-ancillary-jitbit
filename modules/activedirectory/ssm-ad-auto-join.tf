data "template_file" "awsconfig_domain_document" {
  template = file("${path.module}/templates/awsconfig_Domain_template.json.tpl")

  vars = {
    directory_id               = local.directory_id
    directory_name             = local.directory_name
    directory_ou               = "OU=Computers,OU=${local.directory_short_name},DC=${split(".", local.directory_name)[0]},DC=${split(".", local.directory_name)[1]}"
    directory_primary_dns_ip   = local.directory_dns_ips[0]
    directory_secondary_dns_ip = local.directory_dns_ips[1]
  }
}

resource "null_resource" "awsconfig_domain_document_rendered" {
  triggers = {
    json = data.template_file.awsconfig_domain_document.rendered
  }
}

resource "aws_ssm_document" "awsconfig_domain_document" {
  name            = "awsconfig_Domain_${local.directory_id}_${local.directory_name}"
  content         = data.template_file.awsconfig_domain_document.rendered
  document_format = "JSON"
  document_type   = "Command"

  tags = var.common.tags
}
