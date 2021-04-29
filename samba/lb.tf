# # alb
# resource "aws_lb" "storage" {
#   name               = "${local.common_name}-storage-lb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups = [
#     aws_security_group.lb.id,
#     data.terraform_remote_state.common.outputs.sg_outbound_id
#   ]
#   subnets                    = flatten(local.public_subnet_ids)
#   enable_deletion_protection = false

#   access_logs {
#     bucket  = local.lb_logs_bucket
#     prefix  = "${local.common_name}-storage-lb"
#     enabled = true
#   }

#   tags = merge(
#     local.tags,
#     {
#       "Name" = "${local.common_name}-storage-lb"
#     },
#   )

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_lb_target_group" "storage" {
#   name                 = "${local.common_name}-storage-tg"
#   port                 = 80
#   protocol             = "HTTP"
#   vpc_id               = local.vpc_id
#   deregistration_delay = 60
#   target_type          = "instance"

#   health_check {
#     interval            = 30
#     path                = "/"
#     port                = 80
#     protocol            = "HTTP"
#     timeout             = 5
#     healthy_threshold   = 3
#     unhealthy_threshold = 3
#     matcher             = "200-299"
#   }

#   stickiness {
#     type            = "lb_cookie"
#     cookie_duration = local.jitbit_samba_configs["cookie_duration"]
#     enabled         = true
#   }

#   tags = merge(
#     local.tags,
#     {
#       "Name" = "${local.common_name}-storage-tg"
#     },
#   )
# }

# resource "aws_lb_listener" "storage" {
#   load_balancer_arn = aws_lb.storage.arn
#   port              = 445
#   protocol          = "TCP"

#   default_action {
#     target_group_arn = aws_lb_target_group.storage.arn
#     type             = "forward"
#   }
# }

resource "aws_elb" "samba_lb" {
  name     = "${local.common_name}-samba-lb"
  internal = true
  subnets  = flatten(local.subnet_ids)
  tags     = local.tags
  security_groups = [
    aws_security_group.lb.id,
    data.terraform_remote_state.common.outputs.sg_outbound_id
  ]

  access_logs {
    bucket        = local.lb_logs_bucket
    bucket_prefix = "${local.common_name}-samba-lb"
    interval      = 60
    enabled       = true
  }
  listener {
    instance_port     = "445"
    instance_protocol = "tcp"
    lb_port           = "445"
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = "139"
    instance_protocol = "tcp"
    lb_port           = "139"
    lb_protocol       = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:445"
    interval            = 30
  }
}
