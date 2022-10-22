locals {
  timestamp = timestamp()
}

locals {
  tags = {
    TerraformManaged = "true"
    Customer         = "empoly-number"
    Company          = "Amazon Web Services"
    Project          = "Solution Name"
    Description      = "Terraform Test Application IaC"
    Create-Time      = local.timestamp
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = var.region
  alias   = "poc"
  profile = terraform.workspace == "default" ? "poc" : terraform.workspace
}

provider "aws" {
  region  = var.region
  alias   = "sso-org-root"
  profile = terraform.workspace == "sso-org-root" ? "sso-org-root" : terraform.workspace

}


module "vpc" {
  source = "./vpc"

  providers = {
    aws = aws.sso-org-root
  }

  tags           = local.tags
  aws_az         = var.aws_az
  region         = var.region
  aws_az_des     = var.aws_az_des
  private_subnet = var.private_subnet
  public_subnet  = var.public_subnet
  db_subnet      = var.db_subnet
  vpc_cidr       = var.vpc_cidr
}

module "security_group" {
  source = "./sg"

  providers = {
    aws = aws.sso-org-root
  }

  tags     = local.tags
  aws_az   = var.aws_az
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
  sg_rule  = var.sg_rule
}

module "week1_ec2_web" {
  source = "./tf101_week1_ec2"

  providers = {
    aws = aws.sso-org-root
  }

  tags              = local.tags
  aws_az            = var.aws_az
  vpc_cidr          = var.vpc_cidr
  sg_rule           = var.sg_rule
  tf101_server_port = var.tf101_server_port

  vpc_id                = module.vpc.vpc_id
  public_subnet_id_0    = module.vpc.public_subnet_id_0
  public_subnet_id_1    = module.vpc.public_subnet_id_1
  private_subnet_id_0   = module.vpc.private_subnet_id_0
  private_subnet_id_1   = module.vpc.private_subnet_id_1
  db_subnet_id_0        = module.vpc.db_subnet_id_0
  db_subnet_id_1        = module.vpc.db_subnet_id_1
  tls_security_group_id = module.security_group.aws_security_group_id
}

module "week2_alb_asg" {
  source = "./tf101_week2_asg"

  providers = {
    aws = aws.sso-org-root
  }

  tags     = local.tags
  aws_az   = var.aws_az
  vpc_cidr = var.vpc_cidr
  alb_rule = var.alb_rule

  vpc_id              = module.vpc.vpc_id
  public_subnet_id_0  = module.vpc.public_subnet_id_0
  public_subnet_id_1  = module.vpc.public_subnet_id_1
  private_subnet_id_0 = module.vpc.private_subnet_id_0
  private_subnet_id_1 = module.vpc.private_subnet_id_1
  db_subnet_id_0      = module.vpc.db_subnet_id_0
  db_subnet_id_1      = module.vpc.db_subnet_id_1

}
