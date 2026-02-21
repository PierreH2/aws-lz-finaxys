variable "aws_region" {
  description = "AWS region à utiliser pour la création du compte"
  type        = string
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "Profil AWS CLI à utiliser (parent/root)"
  type        = string
  default     = "default"
}

variable "account_name" {
  description = "Nom du nouveau compte AWS Organization"
  type        = string
  default     = "Finaxys-AI-project"
}

variable "account_email" {
  description = "Email du nouveau compte AWS Organization"
  type        = string
  default     = "pierre.huang@finaxys.com"
}

variable "account_role_name" {
  description = "Nom du rôle IAM créé dans le nouveau compte"
  type        = string
  default     = "OrganizationAccountAccessRole"
}

variable "target_ou_name" {
  description = "Nom de l'OU cible sous Root où créer le compte (ex: Lab)"
  type        = string
  default     = "Lab"
}

variable "create_target_ou_if_missing" {
  description = "Créer automatiquement l'OU cible sous Root si elle n'existe pas"
  type        = bool
  default     = true
}

variable "tfstate_bucket_name" {
  description = "Nom du bucket S3 contenant le backend Terraform"
  type        = string
  default     = "ai-project-aws-organisation-tfstate"
}

variable "tfstate_region" {
  description = "Région du bucket S3 backend Terraform"
  type        = string
  default     = "eu-west-1"
}

variable "tfstate_key" {
  description = "Chemin du fichier state dans le bucket S3"
  type        = string
  default     = "bootstrap-aws-account/terraform.tfstate"
}

variable "tfstate_cross_account_allowed_prefixes" {
  description = "Préfixes S3 autorisés pour le rôle cross-account (states distants + lockfiles)"
  type        = list(string)
  default     = ["bootstrap-s3/*", "agentic-research/*"]
}
