variable "tags" {

}

variable "aws_az" {
  type    = list(any)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id_0" {
  type = string
}

variable "public_subnet_id_1" {
  type = string
}

variable "private_subnet_id_0" {
  type = string
}

variable "private_subnet_id_1" {
  type = string
}

variable "db_subnet_id_0" {
  type = string
}

variable "db_subnet_id_1" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "tls_security_group_id" {
  type = string
}

variable "tf101_server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
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
