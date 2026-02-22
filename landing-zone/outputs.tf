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
