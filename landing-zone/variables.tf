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
  default     = "1.29"
}

# LB & Volumes
variable "nlb_name" {
  description = "Nom du Network Load Balancer"
  type        = string
  default     = "agentic-research-nlb"
}
variable "nlb_tg_name" {
  description = "Nom du Target Group du NLB"
  type        = string
  default     = "agentic-research-nlb-tg"
}
variable "ebs_volume_size" {
  description = "Taille des volumes EBS (en Go)"
  type        = number
  default     = 20
}
variable "ebs_volume_type" {
  description = "Type de volume EBS"
  type        = string
  default     = "gp3"
}
variable "ebs_volume_names" {
  description = "Noms des volumes EBS à créer"
  type        = list(string)
  default     = ["agentic-research-data-1", "agentic-research-data-2"]
}
