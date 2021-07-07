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

resource "aws_lb_target_group" "jitbit" {
  name                 = format("%s-tg-canary", local.common_name)
  port                 = 443
  protocol             = "HTTPS"
  vpc_id               = local.vpc_id
  deregistration_delay = 60
  target_type          = "instance"

  health_check {
    interval            = 30
    path                = "/User/Login?ReturnUrl=%2f"
    port                = 443
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = local.jitbit_configs["cookie_duration"]
    enabled         = true
  }

  tags = merge(
    local.tags,
    {
      "Name" = format("%s-tg", local.common_name)
    },
  )
}

resource "aws_lb_listener" "jitbit" {
  load_balancer_arn = aws_lb.jitbit.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = element(local.public_acm_arn, 0)

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jitbit.arn
  }
}

# Route53 entry to jitbit canary lb
resource "aws_route53_record" "jitbit" {
  zone_id = local.public_zone_id
  name    = "helpdeskcanary.${local.external_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.jitbit.dns_name
    zone_id                = aws_lb.jitbit.zone_id
    evaluate_target_health = false
  }
}
