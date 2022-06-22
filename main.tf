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


module "vpc" {
  source = "./vpc"

  providers = {
    aws = aws.poc
  }

  tags           = local.tags
  aws_az         = var.aws_az
  private_subnet = var.private_subnet
  public_subnet  = var.public_subnet
  db_subnet      = var.db_subnet
  vpc_cidr       = var.vpc_cidr
}

module "security_group" {
  source = "./sg"

  providers = {
    aws = aws.poc
  }

  tags     = local.tags
  aws_az   = var.aws_az
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
  sg_rule  = var.sg_rule
}
