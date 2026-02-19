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
data "aws_iam_policy_document" "scp_deny_all_except_s3" {
  statement {
    effect = "Deny"
    actions = ["*"]
    resources = ["*"]
    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }
  statement {
    effect = "Allow"
    actions = ["s3:*"]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "scp_s3_only" {
  name        = "SCP-Allow-S3-Only"
  description = "Deny all except S3 actions"
  content     = data.aws_iam_policy_document.scp_deny_all_except_s3.json
  type        = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "attach_scp" {
  policy_id = aws_organizations_policy.scp_s3_only.id
  target_id = aws_organizations_account.lz_account.id
}
