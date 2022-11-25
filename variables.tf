variable "aws_az" {
  type    = list(any)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "aws_az_des" {
  type    = list(any)
  default = ["apn2a", "apn2c"]
}

variable "db_name" {
  description = "The name to use for the database"
  type        = string
  default     = "sample-db-name"
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "tf101_server_port" {
  type    = number
  default = 5000
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

variable "alb_rule" {
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


variable "aurora_mysql_parameters" {
  type = object({
    cluster = list(object({
      name         = string
      value        = string
      apply_method = string
    }))
    instance = list(object({
      name         = string
      value        = string
      apply_method = string
    }))
  })
}

variable "vault_addr" {
  description = "Vault Server address format : http://IP_ADDRES:8200"
  default     = "http://127.0.0.1:8200"
}

variable login_approle_role_id {
  description = "AppRole ID Value"
}
variable login_approle_secret_id {
  description = "AppRole Secret ID Value"
}