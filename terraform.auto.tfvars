aws_az = [
  "ap-northeast-2a",
  "ap-northeast-2c"
]

aws_az_des = [
  "apn2a",
  "apn2c"
]

region = "ap-northeast-2"

vpc_cidr = "10.0.0.0/16"

private_subnet = [
  "10.0.10.0/24",
  "10.0.20.0/24"
]

public_subnet = [
  "10.0.30.0/24",
  "10.0.40.0/24"
]

db_subnet = [
  "10.0.50.0/24",
  "10.0.60.0/24"
]

tf101_server_port = 8008

sg_rule = {
  ingress = [
    {
      ranges_ipv4 = ["0.0.0.0/0"]
      ranges_ipv6 = []
      protocol    = "TCP"
      to_ports    = 8008
      from_ports  = 8008
      desc        = "8008 Allow"
    },
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

alb_rule = {
  ingress = [
    {
      ranges_ipv4 = ["0.0.0.0/0"]
      ranges_ipv6 = []
      protocol    = "TCP"
      to_ports    = 8008
      from_ports  = 8008
      desc        = "8008 Allow"
    }
  ]
  "egress" = [
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

aurora_mysql_parameters = {
  cluster = [
    {
      name         = "character_set_server"
      value        = "utf8"
      apply_method = "immediate"
    },
    {
      name         = "character_set_client"
      value        = "utf8"
      apply_method = "immediate"
    },
    {
      name         = "performance_schema"
      value        = "0"
      apply_method = "pending-reboot"
    }
  ]
  "instance" = [
    {
      name         = "slow_query_log"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "long_query_time"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "connect_timeout"
      value        = "5"
      apply_method = "immediate"
    },
    {
      name         = "max_connections"
      value        = "16000"
      apply_method = "immediate"
    },
    {
      name         = "performance_schema"
      value        = "0"
      apply_method = "pending-reboot"
    }
  ]
}
