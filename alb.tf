resource "aws_lb_target_group" "tg" {
  name     = "${var.COMPONENT}-${var.ENV}"
  port     = var.APP_PORT
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.VPC_ID
  health_check {
    enabled = true
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 5
    path = "/health"
    port = var.APP_PORT
    timeout = 3
  }
}

//LISTNER DIRECTLY
resource "aws_lb_listener" "lb-listener" {
  count             = var.LB_PUBLIC ? 1:0
  load_balancer_arn = data.terraform_remote_state.alb.outputs.ALB_PUBLIC_ARN
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
// LISTNER RULE
resource "aws_lb_listener_rule" "static" {
  count             = var.LB_PRIVATE ? 1:0
  listener_arn = data.terraform_remote_state.alb.outputs.PRIVATE_LISTENER_ARN
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    host_header {
      values = ["${var.COMPONENT}-${var.ENV}.roboshop.internal"]
    }
  }
}