output vpc_id {
    value = aws_vpc.terraform_module_vpc.id
    description = "vpc id"
}

output "public_subnet_id_0" {
    value = aws_subnet.public_subnet[0].id
    description = "subnet id 0"
}

output "public_subnet_id_1" {
    value = aws_subnet.public_subnet[1].id
    description = "subnet id 1"
}

output "private_subnet_id_0" {
    value = aws_subnet.private_subnet[0].id
    description = "subnet id 0"
}

output "private_subnet_id_1" {
    value = aws_subnet.private_subnet[1].id
    description = "subnet id 1"
}