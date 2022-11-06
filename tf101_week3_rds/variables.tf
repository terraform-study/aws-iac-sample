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

variable "app_sg_id" {
  type = string
}

variable "parameters" {
  type    = list(map(string))
  default = []
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
