variable "aws_console_role" {
  description = "This role will be added to the kubernetes clusters admin users"
  default     = "IibsAdminAccess-DO-NOT-DELETE"
}

variable "region" {
  type = string
  default = "ap-northeast-2"
}

variable "cluster_name" {}

variable "subnet_ids" {}

variable "cluster_version" {
  default = "1.23"
}

variable "node_group_instance_types" {
  default = ["m5.large"]
}

variable "node_group_desired_size" {
  default = 1
}

variable "node_group_max_size" {
  default = 1
}

variable "node_group_min_size" {
  default = 1
}

variable "node_group_max_unavailable" {
  default = 1
}

