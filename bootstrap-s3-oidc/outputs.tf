output "state_bucket_name" {
  description = "Nom du bucket S3"
  value       = aws_s3_bucket.terraform_state.id
}

output "github_actions_role_arn" {
  description = "ARN du rôle GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "backend_config" {
  description = "Configuration backend pour landing-zone"
  value       = <<-EOT
    backend "s3" {
      bucket  = "${aws_s3_bucket.terraform_state.id}"
      key     = "landing-zone/terraform.tfstate"
      region  = "${var.aws_region}"
      encrypt = true
    }
  EOT
}
