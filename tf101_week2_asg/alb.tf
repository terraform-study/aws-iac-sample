resource "aws_lb" "tf101_sample_alb" {
  name               = "tf101-week2-study-alb"
  load_balancer_type = "application"
  subnets            = [var.public_subnet_id_0, var.public_subnet_id_1]
  security_groups = [aws_security_group.alb_tg.id]

  tags = merge(var.tags, {
    Name = "tf101-week2-study-alb"
  })
}


resource "aws_lb_listener" "tf101_sample_alb_listener" {
  load_balancer_arn = aws_lb.tf101_sample_alb.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found - T101 Study"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "tf101_listener_rule" {
  listener_arn = aws_lb_listener.tf101_sample_alb_listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf101_tg_1.arn
  }
}

resource "aws_lb_target_group" "tf101_tg_1" {
  name = "t101-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}