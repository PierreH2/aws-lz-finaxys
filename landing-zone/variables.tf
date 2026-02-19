variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "aws-lz"
}

variable "environment" {
  description = "Environnement"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
  default     = "10.0.0.0/16"
}
