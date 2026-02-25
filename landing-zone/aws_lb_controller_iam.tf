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

