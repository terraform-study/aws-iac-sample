variable "aws_az" {
  type    = list(any)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "aws_az_des" {
 type = list
 default = ["apn2a", "apn2c"]
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnet" {
  type    = list(any)
  default = ["10.0.10.0/24", "10.0.10.0/24"]
}

variable "public_subnet" {
  type    = list(any)
  default = ["10.0.20.0/24", "10.0.30.0/24"]
}

variable "db_subnet" {
  type    = list(any)
  default = ["10.0.40.0/24", "10.0.50.0/24"]
}

variable "sg_rule" {
  type = object({
    ingress = list(object({
      ranges_ipv4 = list(string)
      ranges_ipv6 = list(string)
      protocol    = string
      to_ports    = number
      from_ports  = number
      desc        = string
    }))
    egress = list(object({
      ranges_ipv4 = list(string)
      ranges_ipv6 = list(string)
      protocol    = string
      to_ports    = number
      from_ports  = number
      desc        = string
    }))
  })
}
