output "eks_private_subnet_ids" {
  description = "IDs des subnets privés du cluster EKS"
  value       = module.vpc.private_subnets
}

output "eks_public_subnet_ids" {
  description = "IDs des subnets publics du cluster EKS"
  value       = module.vpc.public_subnets
}

output "eks_oidc_provider" {
  description = "OIDC provider EKS utilisé pour IRSA (sans https://)"
  value       = local.eks_oidc_provider
}
output "ecr_repository_url" {
  value = aws_ecr_repository.main.repository_url
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "node_group_role_arn" {
  value = null
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ebs_csi_driver_role_arn" {
  description = "IAM Role ARN for EBS CSI driver (attach to ebs-csi-controller-sa)"
  value       = aws_iam_role.ebs_csi_driver.arn
}

