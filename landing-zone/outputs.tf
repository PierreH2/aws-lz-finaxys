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
  value = module.eks.node_group_iam_role_arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
