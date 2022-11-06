
data "aws_iam_policy_document" "instance_ssm_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect =  "Allow"
    sid = ""
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance_ssm_role" {
  name               = "AmazonSSMSServiceRole_tf101_week2"
  path               = "/instance-profile/"
  assume_role_policy = data.aws_iam_policy_document.instance_ssm_role_policy.json

  tags = merge(var.tags, {
    Name = "instance_ssm_role"
  })
}

resource "aws_iam_role_policy_attachment" "instance_ssm_role_attachment" {
  role       = aws_iam_role.instance_ssm_role.name
  policy_arn = data.aws_iam_policy.AWS_Managed_SSM_policy.arn
}

resource "aws_iam_role_policy_attachment" "instance_ssm_role_core_attachment" {
  role       = aws_iam_role.instance_ssm_role.name
  policy_arn = data.aws_iam_policy.AWS_Managed_SSM_Core_policy.arn
}

data "aws_iam_policy" "AWS_Managed_SSM_policy" {
  name = "AmazonEC2RoleforSSM"
}

data "aws_iam_policy" "AWS_Managed_SSM_Core_policy" {
  name = "AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "access_ssm_allow" {
  name = "tf101_week2_AllowSSMProfile"
  role = aws_iam_role.instance_ssm_role.name
}
