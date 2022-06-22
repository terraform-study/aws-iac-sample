# locals {
#   allow_tls = [
#     [443, 443, "tcp", ["10.0.10.0/24", "125.5.5.2/32"]],
#     [80, 80, "tcp", ["10.0.20.0/24"]],
#     [8080, 8080, "tcp", ["10.0.30.0/24"]],
#   ]
# }

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_rule["ingress"]
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
    for_each = var.sg_rule["egress"]
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
    Name = "allow_tls"
  })
}

# resource "aws_security_group_rule" "allow_all" {
#   count             = length(local.allow_tls)
#   type              = "ingress"
#   to_port           = local.allow_tls[count.index][0]
#   from_port         = local.allow_tls[count.index][1]
#   protocol          = local.allow_tls[count.index][2]
#   cidr_blocks       = local.allow_tls[count.index][3]
#   security_group_id = aws_security_group.allow_tls.id
# }

