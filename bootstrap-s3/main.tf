terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "ai-project-aws-organisation-tfstate"
    key          = "bootstrap-s3/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region  = var.aws_region

  default_tags {
    tags = {
      Project     = "AWS-LZ"
      Environment = "bootstrap"
      ManagedBy   = "Terraform"
      Owner       = "PierreH2"
    }
  }
}
