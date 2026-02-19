terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

# Créer un nouveau compte AWS Organization
resource "aws_organizations_account" "lz_account" {
  name      = var.account_name
  email     = var.account_email
  role_name = var.account_role_name
  close_on_deletion = false
}

# Exemple de SCP (deny tout sauf S3)

# SCP : autorise EKS, ECR, S3, VPC, IAM, ELB, EC2, CloudWatch, deny tout le reste
data "aws_iam_policy_document" "scp_lz_minimal" {
  statement {
    effect = "Allow"
    actions = [
      "eks:*",
      "ecr:*",
      "s3:*",
      "ec2:*",
      "iam:*",
      "elasticloadbalancing:*",
      "cloudwatch:*",
      "logs:*",
      "kms:*",
      "autoscaling:*",
      "sts:*",
      "cloudformation:*"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Deny"
    actions = ["*"]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "scp_lz_minimal" {
  name        = "SCP-LandingZone-Minimal"
  description = "Autorise uniquement les services nécessaires à la landing zone cloud native"
  content     = data.aws_iam_policy_document.scp_lz_minimal.json
  type        = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "attach_scp" {
  policy_id = aws_organizations_policy.scp_lz_minimal.id
  target_id = aws_organizations_account.lz_account.id
}
