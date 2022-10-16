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

resource "aws_instance" "tf101_instance" {
  # ami           = data.aws_ssm_parameter.amzn2_latest.value
  ami           = data.aws_ami.ubuntu_latest.id
  instance_type = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, SAP Study" > index.html
              nohup busybox httpd -f -p \${var.tf101_server_port} &
              EOF

  vpc_security_group_ids = [
    var.tls_security_group_id
  ]
  subnet_id                   = var.public_subnet_id_0
  associate_public_ip_address = true

  tags = merge(var.tags, {
    Name = "terraform-Study-101"
  })
}

