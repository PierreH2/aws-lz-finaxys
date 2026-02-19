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
}

variable "account_email" {
  description = "Email du nouveau compte AWS Organization"
  type        = string
}

variable "account_role_name" {
  description = "Nom du rôle IAM créé dans le nouveau compte"
  type        = string
  default     = "OrganizationAccountAccessRole"
}
