#####################
# Frontend ALB
#####################
# ALB
resource "aws_lb" "frontend_alb" {

  name               = local.frontend_alb.name
  internal           = false
  load_balancer_type = "application"

  ip_address_type = local.frontend_alb.ip_address_type

  security_groups = local.frontend_alb.security_groups
  subnets         = local.frontend_alb.subnets

}

# blue lister
resource "aws_lb_listener" "frontend_alb" {

  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = local.frontend_alb.lister.port
  protocol          = local.frontend_alb.lister.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_alb.arn
  }
  lifecycle {
    ignore_changes = [default_action]
  }
}

# green lister
resource "aws_lb_listener" "frontend_alb_green" {

  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 10080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_alb_green.arn
  }
  lifecycle {
    ignore_changes = [default_action]
  }
}

# Target group
resource "aws_lb_target_group" "frontend_alb" {

  name             = local.target_group_frontend.name
  target_type      = "ip"
  protocol_version = "HTTP1"
  port             = "80"
  protocol         = "HTTP"
  vpc_id           = data.terraform_remote_state.common.outputs.vpc_id

  deregistration_delay = 10

  health_check {
    interval            = 15
    path                = local.target_group_frontend.health_check
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200"
  }
}


# Green Target group
resource "aws_lb_target_group" "frontend_alb_green" {

  name             = "${var.name}-tg-frontend-green"
  target_type      = "ip"
  protocol_version = "HTTP1"
  port             = "80"
  protocol         = "HTTP"
  vpc_id           = data.terraform_remote_state.common.outputs.vpc_id

  deregistration_delay = 10

  health_check {
    interval            = 15
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200"
  }
}
