variable "tags" {
  
}

variable "aws_az" {
 type = list
 default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "region" {
  type = string
  default = "ap-northeast-2"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "private_subnet" {
    type = list
    default = ["10.10.0.0/24", "10.20.0.0/24"]
}