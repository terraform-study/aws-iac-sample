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
  profile = "sso-org-root"
}

resource "aws_s3_bucket" "mys3bucket" {
  bucket = "mate-backend-tf101-sewoong"
}

# Enable versioning so you can see the full revision history of your state files
resource "aws_s3_bucket_versioning" "mys3bucket_versioning" {
  bucket = aws_s3_bucket.mys3bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "mydynamodbtable" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
