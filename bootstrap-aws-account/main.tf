terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "aws" {
  alias   = "state_backend"
  region  = var.tfstate_region
  profile = var.aws_profile
}

terraform {
  backend "s3" {
    bucket       = "ai-project-aws-organisation-tfstate"
    key          = "bootstrap-aws-account/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}
