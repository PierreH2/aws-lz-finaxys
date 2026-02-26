# IAM user for CI/CD (optional)
resource "aws_iam_user" "cicd" {
  name = "agentic-research-cicd"
}
resource "aws_iam_user_policy_attachment" "cicd_ecr" {
  user       = aws_iam_user.cicd.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
resource "aws_iam_user_policy_attachment" "cicd_eks" {
  user       = aws_iam_user.cicd.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM for EBS CSI driver (IRSA)
data "aws_iam_policy" "ebs_csi_driver" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role" "ebs_csi_driver" {
  name = "AmazonEKS_EBS_CSI_Driver"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = module.eks.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com",
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_attach" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = data.aws_iam_policy.ebs_csi_driver.arn
}

#eks admin role
resource "aws_iam_role" "eks_admin" {
  name = var.eks_admin_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.eks_admin_account_id}:root"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

#aws_lb_controller iam (for provisioning the ALB Ingress Controller with IRSA)
# Data source pour récupérer l'OIDC provider dynamiquement
data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

# OIDC provider extrait de la data source (sans https://)
locals {
  eks_oidc_provider = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}
# IAM Policy pour AWS Load Balancer Controller
resource "aws_iam_policy" "aws_lb_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy pour AWS Load Balancer Controller (ALB Ingress)"
  policy      = file("${path.module}/iam_policy.json")
}

# IAM Role pour IRSA (ServiceAccount Kubernetes)
resource "aws_iam_role" "aws_lb_controller_role" {
  name = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "arn:aws:iam::${var.eks_admin_account_id}:oidc-provider/${local.eks_oidc_provider}"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${local.eks_oidc_provider}:aud" = "sts.amazonaws.com",
          "${local.eks_oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "aws_lb_controller_attach" {
  role       = aws_iam_role.aws_lb_controller_role.name
  policy_arn = aws_iam_policy.aws_lb_controller_policy.arn
}



