# resource "random_password" "db_pw_random"{
#   length           = 16
#   special          = true
#   override_special = "_!%^"
# }

# resource "aws_secretsmanager_secret" "secret_password" {
#   name = "tf101-week3-aurora-password"

#   tags = merge(var.tags, {
#     Name = "tf101-week3-aurora-password"
#   })
# }

# resource "aws_secretsmanager_secret_version" "password" {
#   secret_id = aws_secretsmanager_secret.secret_password.id
#   secret_string = random_password.db_pw_random.result
# }