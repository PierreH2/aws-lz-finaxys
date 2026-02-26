# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets

  enable_irsa                          = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = false
  cluster_endpoint_public_access_cidrs = var.eks_public_access_cidrs

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t3.large"]

      # Utilisation de block_device_mappings au lieu de disk_size
      # méthode recommandée en v20.x pour du gp3 performant
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 120
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 125
            delete_on_termination = true
          }
        }
      }

      # Optionnel : Ajout d'un label pour identifier tes nodes d'IA
      labels = {
        role = "ai-agent"
      }
    }
  }
}

# EBS CSI driver addon (AWS official way)
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = null # latest
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
  depends_on = [module.eks]
}
