data "aws_ssm_parameter" "amzn2_latest" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-5.10-hvm-x86_64-gp2"
}

## amazon linux2 ami latest
data "aws_ami" "amzn_latest" {
  most_recent = true
  owners      = ["amazon"] # Canonical

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

## ubuntu ami latest
data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] # Canonical(owner account id)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_iam_policy_document" "tf101_week1_instance_ssm_role_policy" {
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

resource "aws_iam_role" "tf101_week1_instance_ssm_role" {
  name               = "AmazonSSMSServiceRole_tf101_week1"
  path               = "/instance-profile/"
  assume_role_policy = data.aws_iam_policy_document.tf101_week1_instance_ssm_role_policy.json

  tags = merge(var.tags, {
    Name = "instance_ssm_role"
  })
}

resource "aws_iam_role_policy_attachment" "tf101_week1_instance_ssm_role_attachment" {
  role       = aws_iam_role.tf101_week1_instance_ssm_role.name
  policy_arn = data.aws_iam_policy.tf101_week1_AWS_Managed_SSM_policy.arn
}

resource "aws_iam_role_policy_attachment" "tf101_week1_instance_ssm_role_core_attachment" {
  role       = aws_iam_role.tf101_week1_instance_ssm_role.name
  policy_arn = data.aws_iam_policy.tf101_week1_AWS_Managed_SSM_Core_policy.arn
}

data "aws_iam_policy" "tf101_week1_AWS_Managed_SSM_policy" {
  name = "AmazonEC2RoleforSSM"
}

data "aws_iam_policy" "tf101_week1_AWS_Managed_SSM_Core_policy" {
  name = "AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "tf101_week1_access_ssm_allow" {
  name = "tf101_week1_AllowSSMProfile"
  role = aws_iam_role.tf101_week1_instance_ssm_role.name
}


resource "aws_instance" "tf101_instance" {
  # ami           = data.aws_ssm_parameter.amzn2_latest.value
  ami           = data.aws_ami.ubuntu_latest.id
  instance_type = "t2.micro"

  user_data = <<-EOF
              # #!/bin/bash
              # apt-get update -y
              # apt install apache2 -y
              # sudo sed -i "s/^Listen 80/Listen \${var.tf101_server_port}/g" /etc/apache2/ports.conf
              # sudo systemctl restart apache2.service
              # echo "Hello, SAP Study" > index.html
              #!/bin/bash
              cd /tmp
              sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
              sudo systemctl enable amazon-ssm-agent
              sudo systemctl start amazon-ssm-agent
              sleep 20
              wget https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64
              mv busybox-x86_64 busybox
              chmod +x busybox
              RZAZ=\$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone-id)
              IID=\$(curl 169.254.169.254/latest/meta-data/instance-id)
              LIP=\$(curl 169.254.169.254/latest/meta-data/local-ipv4)
              echo "<h1>RegionAz(\$RZAZ) : Instance ID(\$IID) : Private IP(\$LIP) : Web Server</h1>" > index.html
              nohup ./busybox httpd -f -p ${var.tf101_server_port} &
              EOF

  vpc_security_group_ids = [
    var.tls_security_group_id
  ]
  subnet_id                   = var.public_subnet_id_0
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.tf101_week1_access_ssm_allow.name

  tags = merge(var.tags, {
    Name = "terraform-Study-101"
  })
}