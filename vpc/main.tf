data "aws_region" "current" {}

resource "aws_vpc_ipam" "terraform_ipam" {
  operating_regions {
    region_name = data.aws_region.current.name
  }
}

resource "aws_vpc_ipam_pool" "pool" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.terraform_ipam.private_default_scope_id
  locale         = data.aws_region.current.name
}

resource "aws_vpc_ipam_pool_cidr" "pool_cidr" {
  ipam_pool_id = aws_vpc_ipam_pool.pool.id
  cidr         = var.vpc_cidr
}

resource "aws_vpc" "terraform_module_vpc" {
  # cidr_block = var.vpc_cidr
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.pool.id
  ipv4_netmask_length = 16
  depends_on = [
    aws_vpc_ipam_pool_cidr.pool_cidr
  ]

  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = merge(var.tags, {
    Name = "terraform_module_vpc"
  })
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.aws_az)
  vpc_id                  = aws_vpc.terraform_module_vpc.id
  cidr_block              = var.private_subnet[count.index]
  availability_zone       = var.aws_az[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name                              = "SUB-Private-${var.aws_az_des[count.index]}"
    "kubernetes.io/role/internal-elb" = 1
  })
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.aws_az)
  vpc_id                  = aws_vpc.terraform_module_vpc.id
  cidr_block              = var.public_subnet[count.index]
  availability_zone       = var.aws_az[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name                     = "SUB-Public${var.aws_az_des[count.index]}"
    "kubernetes.io/role/elb" = 1
  })
}

resource "aws_subnet" "db_subnet" {
  count                   = length(var.aws_az)
  vpc_id                  = aws_vpc.terraform_module_vpc.id
  cidr_block              = var.db_subnet[count.index]
  availability_zone       = var.aws_az[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "SUB-DB-${var.aws_az_des[count.index]}"
  })
}
## new line

resource "aws_route_table" "rt_private_db" {
  count      = length(var.aws_az)
  vpc_id     = aws_vpc.terraform_module_vpc.id
  depends_on = [aws_nat_gateway.nat_gw]

  tags = merge(var.tags, {
    Name = "RT-Db-${var.aws_az_des[count.index]}"
  })

  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  # }
}

resource "aws_route_table_association" "rt_private_db_association" {
  count          = length(aws_route_table.rt_private_db)
  subnet_id      = element(aws_subnet.db_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.rt_private_db.*.id, count.index)
}

resource "aws_route_table" "rt_private_nat" {
  count      = length(var.aws_az)
  vpc_id     = aws_vpc.terraform_module_vpc.id
  depends_on = [aws_nat_gateway.nat_gw]

  tags = merge(var.tags, {
    Name = "RT-Private-${var.aws_az_des[count.index]}"
  })

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }
}

resource "aws_route_table_association" "rt_private_nat_association" {
  count          = length(aws_route_table.rt_private_nat)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.rt_private_nat.*.id, count.index)
}

resource "aws_route_table" "rt_public_igw" {
  count      = length(var.aws_az)
  vpc_id     = aws_vpc.terraform_module_vpc.id
  depends_on = [aws_internet_gateway.igw]

  tags = merge(var.tags, {
    Name = "RT-Publuc-${var.aws_az_des[count.index]}"
  })

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rt_public_igw_association" {
  count          = length(aws_route_table.rt_public_igw)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.rt_public_igw.*.id, count.index)
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform_module_vpc.id

  tags = merge(var.tags, {
    Name = "IGW-terraform-module-vpc"
  })
}

## count = 2
## @TODO create Ip count 2 and nat gw count 2
resource "aws_eip" "eip_nat_gw" {
  count = length(var.aws_az)

  tags = merge(var.tags, {
    Name = "EIP-nat-gw-${count.index}"
  })
}

resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.aws_az)
  allocation_id = aws_eip.eip_nat_gw[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = merge(var.tags, {
    Name = "NAT-gw-${var.aws_az_des[count.index]}"
  })
}


resource "aws_vpc_endpoint" "s3_gw_endpoint" {
  vpc_id       = aws_vpc.terraform_module_vpc.id
  service_name = "com.amazonaws.${var.region}.s3"

  vpc_endpoint_type = "Gateway"

  tags = merge(var.tags, {
    Name = "VPCE-GW-s3-${aws_vpc.terraform_module_vpc.id}"
  })
}

resource "aws_vpc_endpoint_route_table_association" "s3_gw_endpoint_private_db_rt" {
  count           = length(aws_route_table.rt_private_db)
  route_table_id  = element(aws_route_table.rt_private_db.*.id, count.index)
  vpc_endpoint_id = aws_vpc_endpoint.s3_gw_endpoint.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_gw_endpoint_private_nat_rt" {
  count           = length(aws_route_table.rt_private_nat)
  route_table_id  = element(aws_route_table.rt_private_nat.*.id, count.index)
  vpc_endpoint_id = aws_vpc_endpoint.s3_gw_endpoint.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_gw_endpoint_public_rt" {
  count           = length(aws_route_table.rt_public_igw)
  route_table_id  = element(aws_route_table.rt_public_igw.*.id, count.index)
  vpc_endpoint_id = aws_vpc_endpoint.s3_gw_endpoint.id
}