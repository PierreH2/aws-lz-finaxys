variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "agentic-research-eks"
}

variable "eks_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.35"
}

variable "eks_public_access_cidrs" {
  description = "CIDRs autorisés à accéder à l'endpoint public de l'API EKS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}


# Rôle IAM dédié à l'administration EKS
variable "eks_admin_role_name" {
  description = "Nom du rôle IAM admin EKS à créer"
  type        = string
  default     = "EKSAdminRole"
}

variable "eks_admin_account_id" {
  description = "ID du compte AWS où créer le rôle (compte cible)"
  type        = string
  default     = "333320350721"
}