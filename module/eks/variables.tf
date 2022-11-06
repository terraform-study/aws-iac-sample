ariable "tags" {

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


variable "vpc_cidr" {
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