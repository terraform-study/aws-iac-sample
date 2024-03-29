data "aws_ami" "amzn2_latest" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

resource "aws_launch_template" "tf101_week2_lc_sample" {
  name_prefix = "tf101-week2-lt-"
  image_id    = data.aws_ami.amzn2_latest.id
  # default_version = 2
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 50
      volume_type = "gp3"
      throughput  = 125
      iops        = 3000
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 50
      volume_type = "gp3"
      throughput  = 125
      iops        = 3000
    }
  }
  # instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.ec2_tg.id]
  # network_interfaces {
  #   associate_public_ip_address = false
  # }

  monitoring {
    enabled = true
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.access_ssm_allow.arn
  }

  # If do not enter an environment variable, it is possible import and use the shell file
  # user_data = filebase64("${path.module}/tf101_week2_lc_ec2.sh")
  user_data = base64encode(
    templatefile(
      "${path.module}/tf101_week2_lc_ec2.sh",
      {
        port = var.web_port
      }
    )
  )

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "tf101_week2_lc_sample"
  })

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      asg = "tf101_week2_lc_sample_create"
    })
  }
}
