# VPC & Subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name = "agentic-research-vpc"
  cidr = var.vpc_cidr
  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  map_public_ip_on_launch = true
  # Les nodes EC2 EKS seront dans les subnets publics pour permettre l'exposition directe des services (ALB, NodePort, etc)
}
