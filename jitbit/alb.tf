# alb
resource "aws_lb" "instance" {
  name               = format("%s-lb", local.common_name)
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

resource "aws_lb_target_group" "instance" {
  name                 = format("%s-tg", local.common_name)
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = local.vpc_id
  deregistration_delay = 60
  target_type          = "instance"

  health_check {
    interval            = 30
    path                = "/User/Login?ReturnUrl=%2f"
    port                = 80
    protocol            = "HTTP"
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

resource "aws_lb_listener" "instance" {
  load_balancer_arn = aws_lb.instance.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.instance.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "instance_https" {
  load_balancer_arn = aws_lb.instance.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = element(local.public_acm_arn, 0)

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance.arn
  }
}

# Route53 entry to jitbit lb
resource "aws_route53_record" "dns_entry" {
  zone_id = local.public_zone_id
  name    = "helpdesk.${local.external_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.instance.dns_name
    zone_id                = aws_lb.instance.zone_id
    evaluate_target_health = false
  }
}
