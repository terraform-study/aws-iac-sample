data "aws_caller_identity" "self" {}

data "aws_iam_policy_document" "cmk_admin_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.self.arn]
    }
  }
}

resource "aws_kms_key" "cmk" {
  policy = data.aws_iam_policy_document.cmk_admin_policy.json
}

# resource "aws_kms_alias" "cmk_alias" {
#   name          = "alias/kms-cmk-tf101"
#   target_key_id = aws_kms_key.cmk.id
# }

# data "aws_kms_secrets" "creds" {
#   secret {
#     name    = "db"
#     payload = file("${path.module}/db-creds.yml.encrypted")
#   }
# }