locals {
  allow_tls = [
    [443, 443, "tcp", ["10.0.10.0/24", "125.5.5.2/32"]],
    [80, 80, "tcp", ["10.0.20.0/24"]],
    [8080, 8080, "tcp", ["10.0.30.0/24"]],
  ]
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = "allow_tls"
  })
}

resource "aws_security_group_rule" "allow_all" {
  count             = length(local.allow_tls)
  type              = "ingress"
  to_port           = local.allow_tls[count.index][0]
  from_port         = local.allow_tls[count.index][1]
  protocol          = local.allow_tls[count.index][2]
  cidr_blocks       = local.allow_tls[count.index][3]
  security_group_id = aws_security_group.allow_tls.id
}

