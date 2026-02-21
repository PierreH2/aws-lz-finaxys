# EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"
  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  enable_irsa     = true

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        for namespace in var.fargate_namespaces : {
          namespace = namespace
        }
      ]
    }
  }
}
