# alb
resource "aws_lb" "samba" {
  name                       = "${local.common_name}-samba"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.samba.id]
  subnets                    = flatten(local.subnet_ids)
  enable_deletion_protection = false

  access_logs {
    bucket  = local.lb_logs_bucket
    prefix  = "${local.common_name}-samba"
    enabled = true
  }

  tags = merge(
    local.tags,
    {
      "Name" = "${local.common_name}-samba"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "samba" {
  name                 = "${local.common_name}-samba"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = local.vpc_id
  deregistration_delay = 60
  target_type          = "instance"

  health_check {
    interval            = 30
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = local.jitbit_samba_configs["cookie_duration"]
    enabled         = true
  }

  tags = merge(
    local.tags,
    {
      "Name" = "${local.common_name}-samba"
    },
  )
}

resource "aws_lb_listener" "environment" {
  load_balancer_arn = aws_lb.samba.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.samba.arn
    type             = "forward"
  }
}
