variable "aws_region" {
  description = "Région AWS pour déployer les ressources"
  type        = string
  default     = "eu-north-1"
}

variable "state_bucket_name" {
  description = "Nom de base du bucket S3 pour le Terraform state (un suffix aléatoire sera ajouté)"
  type        = string
  default     = "aws-lz-ai-agent-terraform-state"
}

variable "github_org" {
  description = "Organisation GitHub pour OIDC"
  type        = string
  default     = "PierreH2"
}

variable "github_repo" {
  description = "Repository GitHub pour OIDC"
  type        = string
  default     = "aws-lz-ai-agent"
}
