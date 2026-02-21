resource "aws_s3_bucket" "tfstate" {
  provider      = aws.state_backend
  bucket        = var.tfstate_bucket_name
  force_destroy = false

  tags = {
    Name      = var.tfstate_bucket_name
    ManagedBy = "Terraform"
    Purpose   = "TerraformState"
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  provider = aws.state_backend
  bucket   = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  provider = aws.state_backend
  bucket   = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  provider = aws.state_backend
  bucket   = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "tfstate_cross_account" {
  statement {
    sid    = "AllowMemberRoleListBucket"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${aws_organizations_account.lz_account.id}:role/${var.account_role_name}"]
    }

    actions = ["s3:ListBucket"]

    resources = [aws_s3_bucket.tfstate.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = var.tfstate_cross_account_allowed_prefixes
    }
  }

  statement {
    sid    = "AllowMemberRoleGetBucketLocation"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${aws_organizations_account.lz_account.id}:role/${var.account_role_name}"]
    }

    actions   = ["s3:GetBucketLocation"]
    resources = [aws_s3_bucket.tfstate.arn]
  }

  statement {
    sid    = "AllowMemberRoleStateObjects"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${aws_organizations_account.lz_account.id}:role/${var.account_role_name}"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      for prefix in var.tfstate_cross_account_allowed_prefixes :
      "${aws_s3_bucket.tfstate.arn}/${prefix}"
    ]
  }
}

resource "aws_s3_bucket_policy" "tfstate_cross_account" {
  provider = aws.state_backend
  bucket   = aws_s3_bucket.tfstate.id
  policy   = data.aws_iam_policy_document.tfstate_cross_account.json
}
