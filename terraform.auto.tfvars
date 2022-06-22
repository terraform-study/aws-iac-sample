aws_az = [
  "ap-northeast-2a",
  "ap-northeast-2c"
]
region = "ap-northeast-2"

vpc_cidr = "10.0.0.0/16"
private_subnet = [
  "10.0.10.0/24",
  "10.0.20.0/24"
]


sg_rule = {
  ingress = [
    {
      ranges_ipv4 = ["10.0.10.0/24", "125.5.5.2/32"]
      ranges_ipv6 = []
      protocol    = "TCP"
      to_ports    = 8080
      from_ports  = 8080
      desc        = "8080 Allow"
    },
    {
      ranges_ipv4 = ["10.0.10.0/24", "125.5.5.2/32"]
      ranges_ipv6 = []
      protocol    = "TCP"
      to_ports    = 443
      from_ports  = 443
      desc        = "443 Allow"
    }
  ]
  "egress" = [
    {
      ranges_ipv4 = ["10.0.10.0/24", "125.5.5.2/32"]
      ranges_ipv6 = ["::/0"]
      protocol    = "TCP"
      to_ports    = 0
      from_ports  = 0
      desc        = "Outbound Allow"
    },
    {
      ranges_ipv4 = ["0.0.0.0/0"]
      ranges_ipv6 = ["::/0"]
      protocol    = "TCP"
      to_ports    = 0
      from_ports  = 0
      desc        = "Outbound Allow"
    }
  ]
}
