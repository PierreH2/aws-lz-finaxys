output "account_id" {
  value = aws_organizations_account.lz_account.id
}
output "account_arn" {
  value = aws_organizations_account.lz_account.arn
}
output "scp_id" {
  value = aws_organizations_policy.scp_s3_only.id
}
