#####################
# Frontend ALB
#####################
# ALB
resource "aws_lb" "frontend_alb" {
  for_each = local.frontend_albs

  name               = each.value.name
  internal           = false
  load_balancer_type = "application"

  ip_address_type = each.value.ip_address_type

  security_groups = each.value.security_groups
  subnets         = each.value.subnets

  tags = {
    Name = each.value.name
  }
}

# lister
resource "aws_lb_listener" "frontend_alb" {
  for_each = local.frontend_albs

  load_balancer_arn = aws_lb.frontend_alb[each.key].arn
  port              = each.value.lister.port
  protocol          = each.value.lister.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_alb[each.value.lister.default_tg].arn
  }
}

# Target group
resource "aws_lb_target_group" "frontend_alb" {
  for_each = local.target_group_frontend

  name             = each.value.name
  target_type      = "ip"
  protocol_version = "HTTP1"
  port             = "80"
  protocol         = "HTTP"
  vpc_id           = data.terraform_remote_state.common.outputs.vpc_id

  deregistration_delay = 10

  health_check {
    interval            = 15
    path                = each.value.health_check
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200"
  }
}
