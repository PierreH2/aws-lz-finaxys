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

output "fargate_profile_arns" {
  value = [for profile in values(module.eks.fargate_profiles) : profile.fargate_profile_arn]
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "efs_file_system_id" {
  value = aws_efs_file_system.app_data.id
}

output "efs_security_group_id" {
  value = aws_security_group.efs.id
}
