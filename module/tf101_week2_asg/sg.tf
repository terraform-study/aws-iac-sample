resource "aws_security_group" "alb_tg" {
  name        = "tf101_week2_alb_tg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.alb_rule["ingress"]
    iterator = ingress
    content {
      cidr_blocks = ingress.value.ranges_ipv4
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_ports
      to_port     = ingress.value.to_ports
      description = ingress.value.desc
    }
  }
  dynamic "egress" {
    for_each = var.alb_rule["egress"]
    iterator = egress
    content {
      cidr_blocks      = egress.value.ranges_ipv4
      ipv6_cidr_blocks = egress.value.ranges_ipv6
      protocol         = egress.value.protocol
      from_port        = egress.value.from_ports
      to_port          = egress.value.to_ports
      description      = egress.value.desc
    }
  }

  tags = merge(var.tags, {
    Name = "alb_tg"
  })
}

resource "aws_security_group" "ec2_tg" {
  name        = "tf101_week2_ec2_tg"
  description = "allow_alb"
  vpc_id      = var.vpc_id
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "all"
    security_groups = [
      aws_security_group.alb_tg.id
    ]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = merge(var.tags, {
    Name = "tf101_week2_ec2_tg"
  })
}
