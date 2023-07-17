# alb
resource "aws_lb" "jitbit" {
  name               = format("%s-lb-canary", local.common_name)
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.lb.id,
    data.terraform_remote_state.common.outputs.sg_outbound_id
  ]
  subnets                    = flatten(local.public_subnet_ids)
  enable_deletion_protection = false

  access_logs {
    bucket  = local.lb_logs_bucket
    prefix  = format("%s-lb", local.common_name)
    enabled = true
  }

  tags = merge(
    local.tags,
    {
      "Name" = format("%s-lb", local.common_name)
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "jitbit" {
  load_balancer_arn = aws_lb.jitbit.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = element(local.public_acm_arn, 0)

  dynamic "default_action" {
    for_each = var.enable_landingpage ? [1] : []
    content {
      type = "fixed-response"
      fixed_response {
        content_type = "text/plain"
        message_body = "Service taken down for maintenance. Please check back soon."
        status_code  = "200"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.enable_landingpage || local.common_name == "cr-jitbit-training" ? [] : [1]
    content {
      type = "forward"
      forward {
        stickiness {
          duration = 1
          enabled  = false
        }
        target_group {
          arn    = module.blue.asg["aws_lb_target_group_arn"]
          weight = 1
        }
        target_group {
          arn    = module.green.asg["aws_lb_target_group_arn"]
          weight = 0
        }
      }
    }
  }

  # Temporary until pipelines for training are removed.
  dynamic "default_action" {
    for_each = local.common_name == "cr-jitbit-training" ? [1] : []
    content {
      type = "fixed-response"
      fixed_response {
        content_type = "text/plain"
        message_body = "Service has been migrated. Please use https://delius-jitbit.hmpps-test.modernisation-platform.service.justice.gov.uk/"
        status_code  = "200"
      }
    }
  }

}

# Route53 entry to jitbit canary lb
resource "aws_route53_record" "jitbit" {
  zone_id = local.public_zone_id
  name    = "helpdesk.${local.external_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.jitbit.dns_name
    zone_id                = aws_lb.jitbit.zone_id
    evaluate_target_health = false
  }
}
