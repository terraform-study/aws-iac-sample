resource "aws_autoscaling_group" "tf101_week2_asg" {
  name = "tf101_week2_asg"

  min_size           = 5
  max_size           = 10
  desired_capacity   = 5
  capacity_rebalance = true

  health_check_type   = "ELB"
  target_group_arns   = [aws_lb_target_group.tf101_tg_1.arn]
#   availability_zones  = var.aws_az
  vpc_zone_identifier = [var.private_subnet_id_0, var.private_subnet_id_1]
#   launch_template {
#     id      = aws_launch_template.tf101_week2_lc_sample.id
#     version = "$Latest"
#   }

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.tf101_week2_lc_sample.id
        version = "$Latest"
      }

      override {
        instance_type     = "c5.large"
        weighted_capacity = "3"
      }

      override {
        instance_type     = "m4.large"
        weighted_capacity = "2"
      }
    }
  }
  tag {
    key                 = "Name"
    value               = "tf101_asg"
    propagate_at_launch = true
  }
}
