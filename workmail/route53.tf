# Strategic *.probation.service.justice.gov.uk public domain
resource "aws_route53_zone" "mail_zone" {
  name = local.mail_public_domain
  tags = merge(
    local.tags,
    {
      "Name" = local.mail_public_domain,
      "Type" = "public"
    },
  )
}
