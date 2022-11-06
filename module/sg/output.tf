output "aws_security_group_id" {
    value = aws_security_group.common_allow_tls.id
    description = "security group id"
}