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
    Name        = "SUB-Private-${var.aws_az_des[count.index]}"
  })
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.aws_az)
  vpc_id                  = aws_vpc.terraform_module_vpc.id
  cidr_block              = var.public_subnet[count.index]
  availability_zone       = var.aws_az[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name        = "SUB-Public${var.aws_az_des[count.index]}"
  })
}

resource "aws_subnet" "db_subnet" {
  count                   = length(var.aws_az)
  vpc_id                  = aws_vpc.terraform_module_vpc.id
  cidr_block              = var.db_subnet[count.index]
  availability_zone       = var.aws_az[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name        = "SUB-DB-${var.aws_az_des[count.index]}"
  })
}
## new line

resource "aws_route_table" "rt_private_nat" {
  count = length(var.aws_az)
  vpc_id = aws_vpc.terraform_module_vpc.id
  depends_on = [ aws_nat_gateway.nat_gw ]

  tags = merge(var.tags, {
    Name = "RT-Private-${var.aws_az_des[count.index]}"
  })

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }
}

resource "aws_route_table" "rt_public_igw" {
  count = length(var.aws_az)
  vpc_id = aws_vpc.terraform_module_vpc.id
  depends_on = [ aws_internet_gateway.igw ]

  tags = merge(var.tags, {
    Name = "RT-Publuc-${var.aws_az_des[count.index]}"
  })

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform_module_vpc.id

  tags = merge(var.tags,{
    Name = "IGW-terraform-module-vpc"
  })
}

## count = 2
## @TODO create Ip count 2 and nat gw count 2
resource "aws_eip" "eip_nat_gw" {
  count = length(var.aws_az)

  tags = merge(var.tags,{
    Name = "EIP-nat-gw-${count.index}"
  })
}

resource "aws_nat_gateway" "nat_gw" {
  count = length(var.aws_az)
  allocation_id = aws_eip.eip_nat_gw[count.index].id
  subnet_id = aws_subnet.public_subnet[count.index].id

  tags = merge(var.tags,{
    Name = "NAT-gw-${var.aws_az_des[count.index]}"
  })
}