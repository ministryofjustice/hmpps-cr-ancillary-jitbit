# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_endpoint
resource "aws_route53_resolver_endpoint" "resolve_local_entries_using_ad_dns" {

  name      = "ForwardDotLocalDNSLookupsToADDNSServersTF"
  direction = "OUTBOUND"

  security_group_ids = [
    module.active_directory.active_directory["security_group_id"]
  ]

  ip_address {
    subnet_id = var.common.subnet_ids[0]
  }

  ip_address {
    subnet_id = var.common.subnet_ids[1]
  }

  tags = var.common.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule
resource "aws_route53_resolver_rule" "r53_fwd_to_ad" {
  domain_name = "${var.common.environment_name}.local"
  name        = "${var.common.environment_name}-local"
  rule_type   = "FORWARD"

  resolver_endpoint_id = aws_route53_resolver_endpoint.resolve_local_entries_using_ad_dns.id

  target_ip {
    ip = module.active_directory.active_directory["dns_ip_addresses"][0]
  }

  target_ip {
    ip = module.active_directory.active_directory["dns_ip_addresses"][1]
  }

  tags = var.common.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule_association
resource "aws_route53_resolver_rule_association" "vpc_r53_fwd_to_ad" {
  resolver_rule_id = aws_route53_resolver_rule.r53_fwd_to_ad.id
  vpc_id           = var.common.vpc_id
}
