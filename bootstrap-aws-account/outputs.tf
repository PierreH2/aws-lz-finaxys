output "account_id" {
  value = aws_organizations_account.lz_account.id
}

output "account_arn" {
  value = aws_organizations_account.lz_account.arn
}

output "scp_id" {
  value = aws_organizations_policy.scp_lz_relaxed.id
}

output "target_parent_ou_id" {
  value = aws_organizations_account.lz_account.parent_id
}

output "tfstate_bucket_name" {
  value = aws_s3_bucket.tfstate.bucket
}

output "tfstate_backend_key" {
  value = var.tfstate_key
}
