terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Décommenter et remplacer le bucket par l'output du bootstrap
  # backend "s3" {
  #   bucket  = "aws-lz-ai-agent-terraform-state-xxxxxxxx"
  #   key     = "landing-zone/terraform.tfstate"
  #   region  = "eu-north-1"
  #   encrypt = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "AWS-LZ-AI-Agent"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "FINAXYS"
    }
  }
}
