variable "aws_region" {
  description = "Région AWS pour déployer les ressources"
  type        = string
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "Profil AWS CLI à utiliser pour ce module"
  type        = string
  default     = ""
}

variable "state_bucket_name" {
  description = "Nom de base du bucket S3 pour le Terraform state (un suffix aléatoire sera ajouté)"
  type        = string
  default     = "ai-agent-project-terraform-state"
}

