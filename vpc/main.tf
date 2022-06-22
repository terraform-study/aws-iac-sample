resource "aws_vpc" "terraform_module_vpc" {
  cidr_block = var.vpc_cidr

  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = merge(var.tags, {
    Name        = "terraform_module_vpc"
  })
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.aws_az)
  vpc_id                  = aws_vpc.terraform_module_vpc.id
  cidr_block              = var.private_subnet[count.index]
  availability_zone       = var.aws_az[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name        = "privete_subnet_${count.index}"
  })
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.aws_az)
  vpc_id                  = aws_vpc.terraform_module_vpc.id
  cidr_block              = var.public_subnet[count.index]
  availability_zone       = var.aws_az[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name        = "public_subnet_${count.index}"
  })
}

resource "aws_subnet" "db_subnet" {
  count                   = length(var.aws_az)
  vpc_id                  = aws_vpc.terraform_module_vpc.id
  cidr_block              = var.db_subnet[count.index]
  availability_zone       = var.aws_az[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name        = "db_subnet_${count.index}"
  })
}